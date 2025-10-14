import React, { useState } from 'react'
import { searchResources, SearchResult } from '../api/client'

export const SearchPage: React.FC = () => {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<SearchResult | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!query.trim()) return

    setLoading(true)
    setError(null)

    try {
      const searchResult = await searchResources({
        query: query.trim(),
        limit: 50
      })
      setResults(searchResult)
    } catch (err) {
      setError('Search failed. Please try again.')
      console.error('Search error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="search-page">
      <div className="search-header">
        <h1>Semantic Search</h1>
        <p>Search your multi-cloud resources using natural language queries</p>
      </div>

      <form onSubmit={handleSearch} className="search-form">
        <div className="search-input-group">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="e.g., 'production web servers in AWS' or 'storage buckets with high cost'"
            className="search-input"
            disabled={loading}
          />
          <button type="submit" disabled={loading || !query.trim()} className="search-button">
            {loading ? 'Searching...' : 'Search'}
          </button>
        </div>
      </form>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      {results && (
        <div className="search-results">
          <div className="results-header">
            <h2>Search Results</h2>
            <div className="results-meta">
              Found {results.total} resources in {results.took_ms}ms
            </div>
          </div>

          {results.resources.length === 0 ? (
            <div className="no-results">
              <p>No resources found for "{results.query}"</p>
              <div className="search-tips">
                <h4>Search Tips:</h4>
                <ul>
                  <li>Try broader terms like "web servers" or "databases"</li>
                  <li>Include provider names: "AWS", "Azure", "GCP"</li>
                  <li>Use resource types: "EC2", "S3", "RDS"</li>
                  <li>Search by tags: "production", "staging", "dev"</li>
                </ul>
              </div>
            </div>
          ) : (
            <div className="results-list">
              {results.resources.map((resource) => (
                <div key={resource.id} className="result-item">
                  <div className="result-header">
                    <h3>{resource.name}</h3>
                    <span className="result-type">{resource.type}</span>
                  </div>
                  
                  <div className="result-details">
                    <span className="provider-badge">{resource.provider}</span>
                    {resource.region && (
                      <span className="region-badge">{resource.region}</span>
                    )}
                    <span className={`status-badge status-${resource.state}`}>
                      {resource.state}
                    </span>
                  </div>

                  {Object.keys(resource.tags).length > 0 && (
                    <div className="result-tags">
                      {Object.entries(resource.tags).slice(0, 3).map(([key, value]) => (
                        <span key={key} className="tag">
                          {key}: {value}
                        </span>
                      ))}
                      {Object.keys(resource.tags).length > 3 && (
                        <span className="more-tags">
                          +{Object.keys(resource.tags).length - 3} more
                        </span>
                      )}
                    </div>
                  )}

                  <div className="result-footer">
                    <span className="resource-id">ID: {resource.id}</span>
                    <span className="last-updated">
                      Updated: {new Date(resource.updated_at).toLocaleDateString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      <style jsx>{`
        .search-page {
          max-width: 800px;
          margin: 0 auto;
        }
        
        .search-header {
          text-align: center;
          margin-bottom: 2rem;
        }
        
        .search-header p {
          color: #666;
          font-size: 1.1rem;
        }
        
        .search-form {
          margin-bottom: 2rem;
        }
        
        .search-input-group {
          display: flex;
          gap: 1rem;
        }
        
        .search-input {
          flex: 1;
          padding: 1rem;
          border: 2px solid #ddd;
          border-radius: 8px;
          font-size: 1rem;
          transition: border-color 0.2s;
        }
        
        .search-input:focus {
          outline: none;
          border-color: #007cba;
        }
        
        .search-button {
          padding: 1rem 2rem;
          background: #007cba;
          color: white;
          border: none;
          border-radius: 8px;
          font-size: 1rem;
          cursor: pointer;
          transition: background-color 0.2s;
        }
        
        .search-button:hover:not(:disabled) {
          background: #005a8b;
        }
        
        .search-button:disabled {
          background: #ccc;
          cursor: not-allowed;
        }
        
        .error-message {
          background: #f8d7da;
          color: #721c24;
          padding: 1rem;
          border-radius: 8px;
          margin-bottom: 1rem;
        }
        
        .results-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1rem;
          padding-bottom: 1rem;
          border-bottom: 2px solid #eee;
        }
        
        .results-meta {
          color: #666;
          font-size: 0.9rem;
        }
        
        .no-results {
          text-align: center;
          padding: 2rem;
          background: white;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .search-tips {
          margin-top: 1.5rem;
          text-align: left;
        }
        
        .search-tips ul {
          color: #666;
        }
        
        .results-list {
          display: flex;
          flex-direction: column;
          gap: 1rem;
        }
        
        .result-item {
          background: white;
          padding: 1.5rem;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .result-item:hover {
          transform: translateY(-1px);
          box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        
        .result-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 1rem;
        }
        
        .result-header h3 {
          margin: 0;
          color: #333;
        }
        
        .result-type {
          background: #e9ecef;
          color: #495057;
          padding: 0.25rem 0.75rem;
          border-radius: 16px;
          font-size: 0.8rem;
        }
        
        .result-details {
          display: flex;
          gap: 0.5rem;
          margin-bottom: 1rem;
          flex-wrap: wrap;
        }
        
        .provider-badge {
          background: #007cba;
          color: white;
          padding: 0.25rem 0.5rem;
          border-radius: 4px;
          font-size: 0.8rem;
          font-weight: bold;
        }
        
        .region-badge {
          background: #6c757d;
          color: white;
          padding: 0.25rem 0.5rem;
          border-radius: 4px;
          font-size: 0.8rem;
        }
        
        .status-badge {
          padding: 0.25rem 0.5rem;
          border-radius: 4px;
          font-size: 0.8rem;
          font-weight: bold;
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
        
        .result-tags {
          display: flex;
          flex-wrap: wrap;
          gap: 0.5rem;
          margin-bottom: 1rem;
        }
        
        .tag {
          background: #f8f9fa;
          color: #495057;
          padding: 0.25rem 0.5rem;
          border-radius: 12px;
          font-size: 0.7rem;
          border: 1px solid #dee2e6;
        }
        
        .more-tags {
          color: #6c757d;
          font-size: 0.7rem;
          padding: 0.25rem 0.5rem;
        }
        
        .result-footer {
          display: flex;
          justify-content: space-between;
          padding-top: 1rem;
          border-top: 1px solid #eee;
          margin-top: 1rem;
        }
        
        .result-footer span {
          color: #999;
          font-size: 0.8rem;
        }
      `}</style>
    </div>
  )
}