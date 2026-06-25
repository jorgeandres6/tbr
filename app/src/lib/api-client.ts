import { ApiResponse } from './types'

const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'

class ApiClient {
  private baseUrl: string

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    try {
      const url = `${this.baseUrl}${endpoint}`
      const response = await fetch(url, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
        ...options,
      })

      if (!response.ok) {
        const error = await response.json()
        return {
          error: {
            message: error.message || 'An error occurred',
            code: error.code,
          },
        }
      }

      const data = await response.json()
      return { data }
    } catch (error) {
      return {
        error: {
          message: error instanceof Error ? error.message : 'An error occurred',
        },
      }
    }
  }

  // Auth endpoints
  async signup(email: string, password: string, role: 'tenant' | 'owner') {
    return this.request('/api/auth/signup', {
      method: 'POST',
      body: JSON.stringify({ email, password, role }),
    })
  }

  async login(email: string, password: string) {
    return this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })
  }

  async logout() {
    return this.request('/api/auth/logout', {
      method: 'POST',
    })
  }

  // Properties endpoints
  async getProperties(city?: string, limit: number = 10) {
    const params = new URLSearchParams()
    if (city) params.append('city', city)
    params.append('limit', limit.toString())

    return this.request(`/api/properties?${params.toString()}`)
  }

  async getPropertyStack(city: string, limit: number = 10) {
    const params = new URLSearchParams()
    params.append('city', city)
    params.append('limit', limit.toString())

    return this.request(`/api/properties/stack?${params.toString()}`)
  }

  async createProperty(data: unknown) {
    return this.request('/api/properties', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Swipes endpoints
  async createSwipe(propertyId: string, action: string) {
    return this.request('/api/swipes', {
      method: 'POST',
      body: JSON.stringify({
        property_id: propertyId,
        action,
      }),
    })
  }

  async getMySwipes() {
    return this.request('/api/swipes')
  }

  // Matches endpoints
  async getMatches() {
    return this.request('/api/matches')
  }

  async approveMatch(matchId: string) {
    return this.request(`/api/matches/${matchId}/approve`, {
      method: 'POST',
    })
  }

  async declineMatch(matchId: string) {
    return this.request(`/api/matches/${matchId}/decline`, {
      method: 'POST',
    })
  }

  // Chat endpoints
  async getConversations() {
    return this.request('/api/chat/conversations')
  }

  async getMessages(conversationId: string) {
    return this.request(`/api/chat/${conversationId}/messages`)
  }

  async sendMessage(conversationId: string, message: string) {
    return this.request(`/api/chat/${conversationId}/messages`, {
      method: 'POST',
      body: JSON.stringify({ message_body: message }),
    })
  }

  // Profile endpoints
  async getTenantProfile() {
    return this.request('/api/profiles/tenant')
  }

  async updateTenantProfile(data: unknown) {
    return this.request('/api/profiles/tenant', {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  async getOwnerProfile() {
    return this.request('/api/profiles/owner')
  }

  async updateOwnerProfile(data: unknown) {
    return this.request('/api/profiles/owner', {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }
}

export const apiClient = new ApiClient(apiUrl)
