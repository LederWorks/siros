package providers

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/LederWorks/siros/backend/internal/config"
	"github.com/LederWorks/siros/backend/pkg/types"
	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	ec2types "github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/aws-sdk-go-v2/service/rds"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// AWSProvider implements the Provider interface for AWS
type AWSProvider struct {
	config config.AWSConfig
	awsCfg aws.Config
}

// NewAWSProvider creates a new AWS provider
func NewAWSProvider(cfg config.AWSConfig) (*AWSProvider, error) {
	// Load AWS configuration
	awsCfg, err := awsconfig.LoadDefaultConfig(context.Background(),
		awsconfig.WithRegion(cfg.Region),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to load AWS config: %w", err)
	}

	return &AWSProvider{
		config: cfg,
		awsCfg: awsCfg,
	}, nil
}

// Name returns the provider name
func (p *AWSProvider) Name() string {
	return "aws"
}

// Validate validates the AWS configuration
func (p *AWSProvider) Validate() error {
	// Test AWS credentials by making a simple API call
	ec2Client := ec2.NewFromConfig(p.awsCfg)
	_, err := ec2Client.DescribeRegions(context.Background(), &ec2.DescribeRegionsInput{})
	if err != nil {
		return fmt.Errorf("AWS credential validation failed: %w", err)
	}
	return nil
}

// Scan scans AWS for resources
func (p *AWSProvider) Scan(ctx context.Context) ([]types.Resource, error) {
	var resources []types.Resource

	// Scan EC2 instances
	ec2Resources, err := p.scanEC2Instances(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to scan EC2 instances: %w", err)
	}
	resources = append(resources, ec2Resources...)

	// Scan S3 buckets
	s3Resources, err := p.scanS3Buckets(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to scan S3 buckets: %w", err)
	}
	resources = append(resources, s3Resources...)

	// Scan RDS instances
	rdsResources, err := p.scanRDSInstances(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to scan RDS instances: %w", err)
	}
	resources = append(resources, rdsResources...)

	return resources, nil
}

// scanEC2Instances scans for EC2 instances
func (p *AWSProvider) scanEC2Instances(ctx context.Context) ([]types.Resource, error) {
	ec2Client := ec2.NewFromConfig(p.awsCfg)

	result, err := ec2Client.DescribeInstances(ctx, &ec2.DescribeInstancesInput{})
	if err != nil {
		return nil, err
	}

	var resources []types.Resource
	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			resource := types.Resource{
				ID:       aws.ToString(instance.InstanceId),
				Type:     "ec2.instance",
				Provider: "aws",
				Region:   p.config.Region,
				Name:     p.getInstanceName(instance.Tags),
				ARN:      fmt.Sprintf("arn:aws:ec2:%s::instance/%s", p.config.Region, aws.ToString(instance.InstanceId)),
				Tags:     p.convertEC2Tags(instance.Tags),
				Metadata: map[string]interface{}{
					"instance_type":   string(instance.InstanceType),
					"state":           string(instance.State.Name),
					"vpc_id":          aws.ToString(instance.VpcId),
					"subnet_id":       aws.ToString(instance.SubnetId),
					"private_ip":      aws.ToString(instance.PrivateIpAddress),
					"public_ip":       aws.ToString(instance.PublicIpAddress),
					"launch_time":     instance.LaunchTime,
					"security_groups": p.convertSecurityGroups(instance.SecurityGroups),
				},
				State:     p.convertEC2State(instance.State.Name),
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}
			resources = append(resources, resource)
		}
	}

	return resources, nil
}

// scanS3Buckets scans for S3 buckets
func (p *AWSProvider) scanS3Buckets(ctx context.Context) ([]types.Resource, error) {
	s3Client := s3.NewFromConfig(p.awsCfg)

	result, err := s3Client.ListBuckets(ctx, &s3.ListBucketsInput{})
	if err != nil {
		return nil, err
	}

	var resources []types.Resource
	for _, bucket := range result.Buckets {
		bucketName := aws.ToString(bucket.Name)

		// Get bucket location
		location, err := s3Client.GetBucketLocation(ctx, &s3.GetBucketLocationInput{
			Bucket: bucket.Name,
		})
		region := p.config.Region
		if err == nil && location.LocationConstraint != "" {
			region = string(location.LocationConstraint)
		}

		resource := types.Resource{
			ID:       bucketName,
			Type:     "s3.bucket",
			Provider: "aws",
			Region:   region,
			Name:     bucketName,
			ARN:      fmt.Sprintf("arn:aws:s3:::%s", bucketName),
			Tags:     make(map[string]string),
			Metadata: map[string]interface{}{
				"creation_date": bucket.CreationDate,
			},
			State:     types.ResourceStateActive,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		resources = append(resources, resource)
	}

	return resources, nil
}

// scanRDSInstances scans for RDS instances
func (p *AWSProvider) scanRDSInstances(ctx context.Context) ([]types.Resource, error) {
	rdsClient := rds.NewFromConfig(p.awsCfg)

	result, err := rdsClient.DescribeDBInstances(ctx, &rds.DescribeDBInstancesInput{})
	if err != nil {
		return nil, err
	}

	var resources []types.Resource
	for _, instance := range result.DBInstances {
		resource := types.Resource{
			ID:       aws.ToString(instance.DBInstanceIdentifier),
			Type:     "rds.instance",
			Provider: "aws",
			Region:   p.config.Region,
			Name:     aws.ToString(instance.DBInstanceIdentifier),
			ARN:      aws.ToString(instance.DBInstanceArn),
			Tags:     make(map[string]string), // RDS tags require separate API call
			Metadata: map[string]interface{}{
				"engine":         aws.ToString(instance.Engine),
				"engine_version": aws.ToString(instance.EngineVersion),
				"instance_class": aws.ToString(instance.DBInstanceClass),
				"status":         aws.ToString(instance.DBInstanceStatus),
				"endpoint":       aws.ToString(instance.Endpoint.Address),
				"port":           instance.Endpoint.Port,
				"storage":        instance.AllocatedStorage,
				"storage_type":   aws.ToString(instance.StorageType),
			},
			State:     p.convertRDSState(aws.ToString(instance.DBInstanceStatus)),
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		resources = append(resources, resource)
	}

	return resources, nil
}

// GetResource retrieves a specific resource by ID
func (p *AWSProvider) GetResource(id string) (*types.Resource, error) {
	// Determine resource type from ID and fetch accordingly
	if strings.HasPrefix(id, "i-") {
		return p.getEC2Instance(id)
	}

	// For S3 buckets and RDS, we'd need different logic
	return nil, fmt.Errorf("resource type not supported for direct fetch: %s", id)
}

// getEC2Instance retrieves a specific EC2 instance
func (p *AWSProvider) getEC2Instance(instanceID string) (*types.Resource, error) {
	ec2Client := ec2.NewFromConfig(p.awsCfg)

	result, err := ec2Client.DescribeInstances(context.Background(), &ec2.DescribeInstancesInput{
		InstanceIds: []string{instanceID},
	})
	if err != nil {
		return nil, err
	}

	if len(result.Reservations) == 0 || len(result.Reservations[0].Instances) == 0 {
		return nil, fmt.Errorf("instance not found: %s", instanceID)
	}

	instance := result.Reservations[0].Instances[0]
	resource := types.Resource{
		ID:       aws.ToString(instance.InstanceId),
		Type:     "ec2.instance",
		Provider: "aws",
		Region:   p.config.Region,
		Name:     p.getInstanceName(instance.Tags),
		ARN:      fmt.Sprintf("arn:aws:ec2:%s::instance/%s", p.config.Region, aws.ToString(instance.InstanceId)),
		Tags:     p.convertEC2Tags(instance.Tags),
		Metadata: map[string]interface{}{
			"instance_type":   string(instance.InstanceType),
			"state":           string(instance.State.Name),
			"vpc_id":          aws.ToString(instance.VpcId),
			"subnet_id":       aws.ToString(instance.SubnetId),
			"private_ip":      aws.ToString(instance.PrivateIpAddress),
			"public_ip":       aws.ToString(instance.PublicIpAddress),
			"launch_time":     instance.LaunchTime,
			"security_groups": p.convertSecurityGroups(instance.SecurityGroups),
		},
		State:     p.convertEC2State(instance.State.Name),
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	return &resource, nil
}

// Helper methods
func (p *AWSProvider) getInstanceName(tags []ec2types.Tag) string {
	for _, tag := range tags {
		if aws.ToString(tag.Key) == "Name" {
			return aws.ToString(tag.Value)
		}
	}
	return "unnamed"
}

func (p *AWSProvider) convertEC2Tags(tags []ec2types.Tag) map[string]string {
	result := make(map[string]string)
	for _, tag := range tags {
		result[aws.ToString(tag.Key)] = aws.ToString(tag.Value)
	}
	return result
}

func (p *AWSProvider) convertSecurityGroups(groups []ec2types.GroupIdentifier) []map[string]string {
	result := make([]map[string]string, len(groups))
	for i, group := range groups {
		result[i] = map[string]string{
			"id":   aws.ToString(group.GroupId),
			"name": aws.ToString(group.GroupName),
		}
	}
	return result
}

func (p *AWSProvider) convertEC2State(state ec2types.InstanceStateName) types.ResourceState {
	switch state {
	case ec2types.InstanceStateNameRunning:
		return types.ResourceStateActive
	case ec2types.InstanceStateNameStopped, ec2types.InstanceStateNameStopping:
		return types.ResourceStateInactive
	case ec2types.InstanceStateNameTerminated:
		return types.ResourceStateTerminated
	default:
		return types.ResourceStateUnknown
	}
}

func (p *AWSProvider) convertRDSState(state string) types.ResourceState {
	switch strings.ToLower(state) {
	case "available":
		return types.ResourceStateActive
	case "stopped", "stopping":
		return types.ResourceStateInactive
	case "deleting", "deleted":
		return types.ResourceStateTerminated
	default:
		return types.ResourceStateUnknown
	}
}
