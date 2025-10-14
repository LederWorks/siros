import React, { ReactNode } from 'react'
import { Link, useLocation } from 'react-router-dom'

interface LayoutProps {
  children: ReactNode
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation()

  const isActive = (path: string) => location.pathname === path

  return (
    <div className="layout">
      <nav className="navbar">
        <div className="nav-brand">
          <h1>🌐 Siros</h1>
          <span className="nav-subtitle">Multi-Cloud Resource Platform</span>
        </div>
        <div className="nav-links">
          <Link to="/" className={isActive('/') ? 'nav-link active' : 'nav-link'}>
            Dashboard
          </Link>
          <Link to="/resources" className={isActive('/resources') ? 'nav-link active' : 'nav-link'}>
            Resources
          </Link>
          <Link to="/graph" className={isActive('/graph') ? 'nav-link active' : 'nav-link'}>
            Graph View
          </Link>
          <Link to="/search" className={isActive('/search') ? 'nav-link active' : 'nav-link'}>
            Search
          </Link>
        </div>
      </nav>
      <main className="main-content">
        {children}
      </main>
      <style jsx>{`
        .layout {
          min-height: 100vh;
          display: flex;
          flex-direction: column;
        }
        
        .navbar {
          background: #1a1a1a;
          color: white;
          padding: 1rem 2rem;
          display: flex;
          justify-content: space-between;
          align-items: center;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .nav-brand h1 {
          margin: 0;
          font-size: 1.5rem;
        }
        
        .nav-subtitle {
          font-size: 0.8rem;
          opacity: 0.7;
        }
        
        .nav-links {
          display: flex;
          gap: 1rem;
        }
        
        .nav-link {
          color: white;
          text-decoration: none;
          padding: 0.5rem 1rem;
          border-radius: 4px;
          transition: background-color 0.2s;
        }
        
        .nav-link:hover {
          background-color: rgba(255,255,255,0.1);
        }
        
        .nav-link.active {
          background-color: #646cff;
        }
        
        .main-content {
          flex: 1;
          padding: 2rem;
          background: #f5f5f5;
        }
      `}</style>
    </div>
  )
}