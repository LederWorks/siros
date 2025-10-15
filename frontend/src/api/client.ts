// API client for Siros backend
const API_BASE = '/api/v1'

export interface Resource {
  id: string
  type: string
  provider: string
  region?: string
  name: string
  arn?: string
  tags: Record<string, string>
  metadata: Record<string, any>
  state: string
  parent_id?: string
  children?: string[]
  created_at: string
  updated_at: string
}

export interface SearchQuery {
  query: string
  filters?: Record<string, string>
  providers?: string[]
  types?: string[]
  limit?: number
  offset?: number
}

export interface SearchResult {
  resources: Resource[]
  total: number
  query: string
  took_ms: number
}

export async function fetchResources(filters?: Record<string, string>): Promise<Resource[]> {
  const params = new URLSearchParams()
  if (filters) {
    Object.entries(filters).forEach(([key, value]) => {
      params.append(key, value)
    })
  }
  
  const response = await fetch(`${API_BASE}/resources?${params}`)
  if (!response.ok) {
    throw new Error('Failed to fetch resources')
  }
  
  const result = await response.json()
  return result.data || []
}

export async function fetchResource(id: string): Promise<Resource> {
  const response = await fetch(`${API_BASE}/resources/${id}`)
  if (!response.ok) {
    throw new Error(`Failed to fetch resource ${id}`)
  }
  
  const result = await response.json()
  return result.data
}

export async function searchResources(query: SearchQuery): Promise<SearchResult> {
  const response = await fetch(`${API_BASE}/search`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(query),
  })
  
  if (!response.ok) {
    throw new Error('Search failed')
  }
  
  const result = await response.json()
  return result.data
}

export async function createResource(resource: Partial<Resource>): Promise<Resource> {
  const response = await fetch(`${API_BASE}/resources`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(resource),
  })
  
  if (!response.ok) {
    throw new Error('Failed to create resource')
  }
  
  const result = await response.json()
  return result.data
}

export async function updateResource(id: string, resource: Partial<Resource>): Promise<Resource> {
  const response = await fetch(`${API_BASE}/resources/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(resource),
  })
  
  if (!response.ok) {
    throw new Error('Failed to update resource')
  }
  
  const result = await response.json()
  return result.data
}

export async function deleteResource(id: string): Promise<void> {
  const response = await fetch(`${API_BASE}/resources/${id}`, {
    method: 'DELETE',
  })
  
  if (!response.ok) {
    throw new Error('Failed to delete resource')
  }
}

export async function healthCheck(): Promise<any> {
  const response = await fetch(`${API_BASE}/health`)
  if (!response.ok) {
    throw new Error('Health check failed')
  }
  return response.json()
}