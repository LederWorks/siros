import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { Dashboard } from './pages/Dashboard'
import { ResourcesPage } from './pages/ResourcesPage'
import { GraphView } from './pages/GraphView'
import { SearchPage } from './pages/SearchPage'
import './App.css'

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/resources" element={<ResourcesPage />} />
          <Route path="/graph" element={<GraphView />} />
          <Route path="/search" element={<SearchPage />} />
        </Routes>
      </Layout>
    </Router>
  )
}

export default App