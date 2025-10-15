import React, { useEffect, useState } from 'react'
import { fetchResources, Resource } from '../api/client'

export const ResourcesPage: React.FC = () => {
  const [resources, setResources] = useState<Resource[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('')

  useEffect(() => {
    const loadResources = async () => {
      try {
        const data = await fetchResources()
        setResources(data)
      } catch (error) {
        console.error('Failed to load resources:', error)
      } finally {
        setLoading(false)
      }
    }

    loadResources()
  }, [])

  const filteredResources = resources.filter(resource =>
    resource.name.toLowerCase().includes(filter.toLowerCase()) ||
    resource.type.toLowerCase().includes(filter.toLowerCase()) ||
    resource.provider.toLowerCase().includes(filter.toLowerCase())
  )

  if (loading) {
    return <div className="loading">Loading resources...</div>
  }

  return (
    <div className="resources-page">
      <div className="page-header">
        <h1>Resources</h1>
        <input
          type="text"
          placeholder="Filter resources..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="filter-input"
        />
      </div>

      <div className="resources-grid">
        {filteredResources.length === 0 ? (
          <div className="empty-state">
            <p>No resources found.</p>
            <small>Try connecting your cloud providers or adjusting your filter.</small>
          </div>
        ) : (
          filteredResources.map((resource) => (
            <div key={resource.id} className="resource-card">
              <div className="resource-header">
                <h3>{resource.name}</h3>
                <span className={`status status-${resource.state}`}>
                  {resource.state}
                </span>
              </div>
              
              <div className="resource-details">
                <p><strong>Type:</strong> {resource.type}</p>
                <p><strong>Provider:</strong> {resource.provider}</p>
                {resource.region && (
                  <p><strong>Region:</strong> {resource.region}</p>
                )}
              </div>
              
              {Object.keys(resource.tags).length > 0 && (
                <div className="resource-tags">
                  {Object.entries(resource.tags).map(([key, value]) => (
                    <span key={key} className="tag">
                      {key}: {value}
                    </span>
                  ))}
                </div>
              )}
              
              <div className="resource-footer">
                <small>ID: {resource.id}</small>
                <small>Updated: {new Date(resource.updated_at).toLocaleDateString()}</small>
              </div>
            </div>
          ))
        )}
      </div>

      <style>{`
        .resources-page {
          max-width: 1200px;
          margin: 0 auto;
        }
        
        .page-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 2rem;
        }
        
        .filter-input {
          padding: 0.5rem 1rem;
          border: 1px solid #ddd;
          border-radius: 4px;
          font-size: 1rem;
          width: 250px;
        }
        
        .loading {
          text-align: center;
          padding: 2rem;
          font-size: 1.2rem;
        }
        
        .empty-state {
          text-align: center;
          padding: 3rem;
          background: white;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .resources-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
          gap: 1.5rem;
        }
        
        .resource-card {
          background: white;
          border-radius: 8px;
          padding: 1.5rem;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .resource-card:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        
        .resource-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 1rem;
        }
        
        .resource-header h3 {
          margin: 0;
          color: #333;
        }
        
        .status {
          padding: 0.25rem 0.75rem;
          border-radius: 16px;
          font-size: 0.8rem;
          font-weight: bold;
          text-transform: uppercase;
        }
        
        .status-active {
          background: #d4edda;
          color: #155724;
        }
        
        .status-inactive {
          background: #f8d7da;
          color: #721c24;
        }
        
        .status-unknown {
          background: #d1ecf1;
          color: #0c5460;
        }
        
        .resource-details p {
          margin: 0.5rem 0;
          color: #666;
        }
        
        .resource-tags {
          display: flex;
          flex-wrap: wrap;
          gap: 0.5rem;
          margin: 1rem 0;
        }
        
        .tag {
          background: #007cba;
          color: white;
          padding: 0.25rem 0.5rem;
          border-radius: 12px;
          font-size: 0.7rem;
        }
        
        .resource-footer {
          display: flex;
          justify-content: space-between;
          padding-top: 1rem;
          border-top: 1px solid #eee;
          margin-top: 1rem;
        }
        
        .resource-footer small {
          color: #999;
          font-size: 0.8rem;
        }
      `}</style>
    </div>
  )
}