-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create additional indexes for better performance
-- (These will be created by the application, but can be pre-created here)

-- Example: Add any custom database initialization here
-- INSERT INTO schemas (id, name, version, provider, type, properties, required, is_custom) 
-- VALUES ('aws-ec2-instance', 'EC2 Instance', '1.0', 'aws', 'ec2.instance', '{}', '{}', false);