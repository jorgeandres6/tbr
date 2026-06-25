export interface User {
  id: string
  email: string
  role: 'tenant' | 'owner'
  profile_completed: boolean
  created_at: string
  updated_at: string
}

export interface TenantProfile {
  tenant_id: string
  description: string
  income_range_id: string
  occupation: string
  verification_status: 'pending' | 'verified' | 'rejected'
  verified_at?: string
}

export interface OwnerProfile {
  owner_id: string
  business_name: string
  verification_status: 'pending' | 'verified' | 'rejected'
  auto_match_enabled: boolean
  verified_at?: string
}

export interface Property {
  property_id: string
  owner_id: string
  title: string
  description: string
  price_monthly?: number
  price_sale?: number
  area_sqm: number
  bedrooms: number
  bathrooms: number
  floors: number
  parking_spaces: number
  floor_number: number
  has_elevator: boolean
  pet_friendly: boolean
  monthly_aliquot: number
  amenities: string[]
  extra_areas: string[]
  address: string
  city: string
  listing_status: 'active' | 'inactive' | 'rented'
  created_at: string
  updated_at: string
}

export interface Swipe {
  swipe_id: string
  tenant_id: string
  property_id: string
  owner_id: string
  action: 'like' | 'dislike' | 'later'
  request_status: 'pending' | 'owner_viewed' | 'owner_declined'
  created_at: string
  updated_at: string
}

export interface Match {
  match_id: string
  tenant_id: string
  property_id: string
  owner_id: string
  status: 'pending_owner_approval' | 'matched' | 'declined'
  tenant_docs_revealed: boolean
  owner_docs_revealed: boolean
  guarantor_info_revealed: boolean
  matched_at?: string
  created_at: string
  updated_at: string
}

export interface ChatConversation {
  conversation_id: string
  tenant_id: string
  owner_id: string
  property_id: string
  last_message_at?: string
  created_at: string
}

export interface ChatMessage {
  message_id: string
  conversation_id: string
  sender_id: string
  recipient_id: string
  message_body: string
  read_at?: string
  created_at: string
}

export interface DocumentationHub {
  doc_id: string
  user_id: string
  document_type: string
  file_url: string
  visibility_status: 'private' | 'guarantor_visible' | 'match_visible' | 'public'
  is_encrypted: boolean
  created_at: string
  updated_at: string
}

export type ApiResponse<T> = {
  data?: T
  error?: {
    message: string
    code?: string
  }
}
