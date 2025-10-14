import React, { useEffect, useState } from 'react'
import { healthCheck } from '../api/client'

export const Dashboard: React.FC = () => {
  const [health, setHealth] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const healthData = await healthCheck()
        setHealth(healthData)
      } catch (error) {
        console.error('Health check failed:', error)
      } finally {
        setLoading(false)
      }
    }

    checkHealth()
  }, [])

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      
      <div className="stats-grid">
        <div className="stat-card">
          <h3>System Status</h3>
          {loading ? (
            <p>Checking...</p>
          ) : health ? (
            <div>
              <p className="status-ok">✅ Online</p>
              <small>API Version: {health.data?.version || 'Unknown'}</small>
            </div>
          ) : (
            <p className="status-error">❌ Offline</p>
          )}
        </div>
        
        <div className="stat-card">
          <h3>Features</h3>
          <ul>
            <li>✅ Multi-Cloud Integration</li>
            <li>✅ Vector Search</li>
            <li>✅ API Interfaces</li>
            <li>✅ Change Tracking</li>
          </ul>
        </div>
        
        <div className="stat-card">
          <h3>Supported Providers</h3>
          <div className="providers">
            <span className="provider">AWS</span>
            <span className="provider">Azure</span>
            <span className="provider">GCP</span>
          </div>
        </div>
        
        <div className="stat-card">
          <h3>Quick Actions</h3>
          <div className="actions">
            <button onClick={() => window.location.href = '/resources'}>
              View Resources
            </button>
            <button onClick={() => window.location.href = '/search'}>
              Search Resources
            </button>
          </div>
        </div>
      </div>
      
      <style jsx>{`
        .dashboard {
          max-width: 1200px;
          margin: 0 auto;
        }
        
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 1.5rem;
          margin-top: 2rem;
        }
        
        .stat-card {
          background: white;
          padding: 1.5rem;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .stat-card h3 {
          margin-top: 0;
          color: #333;
        }
        
        .status-ok {
          color: #28a745;
          font-weight: bold;
          margin: 0;
        }
        
        .status-error {
          color: #dc3545;
          font-weight: bold;
          margin: 0;
        }
        
        .stat-card ul {
          list-style: none;
          padding: 0;
          margin: 0;
        }
        
        .stat-card li {
          padding: 0.25rem 0;
        }
        
        .providers {
          display: flex;
          gap: 0.5rem;
          flex-wrap: wrap;
        }
        
        .provider {
          background: #007cba;
          color: white;
          padding: 0.25rem 0.75rem;
          border-radius: 16px;
          font-size: 0.8rem;
        }
        
        .actions {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
        }
        
        .actions button {
          background: #007cba;
          color: white;
          border: none;
          padding: 0.5rem 1rem;
          border-radius: 4px;
          cursor: pointer;
          transition: background-color 0.2s;
        }
        
        .actions button:hover {
          background: #005a8b;
        }
      `}</style>
    </div>
  )
}