import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { z } from 'zod'

const swipeSchema = z.object({
  property_id: z.string(),
  action: z.enum(['like', 'dislike', 'later']),
})

export async function GET(request: NextRequest) {
  try {
    // Get authenticated user - simplified for MVP
    const userId = request.headers.get('x-user-id')

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const { data, error } = await supabaseServer
      .from('swipes')
      .select('*')
      .eq('tenant_id', userId)
      .order('created_at', { ascending: false })

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get swipes error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch swipes' } },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const userId = request.headers.get('x-user-id')

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const body = await request.json()
    const { property_id, action } = swipeSchema.parse(body)

    // Get property owner
    const { data: property } = await supabaseServer
      .from('properties')
      .select('owner_id')
      .eq('property_id', property_id)
      .single()

    if (!property) {
      return NextResponse.json(
        { error: { message: 'Property not found' } },
        { status: 404 }
      )
    }

    // Create swipe
    const { data, error } = await supabaseServer
      .from('swipes')
      .insert({
        tenant_id: userId,
        property_id,
        owner_id: property.owner_id,
        action,
      })
      .select()

    if (error) {
      throw error
    }

    return NextResponse.json({ data }, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: { message: 'Invalid input' } },
        { status: 400 }
      )
    }

    console.error('Create swipe error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to create swipe' } },
      { status: 500 }
    )
  }
}
