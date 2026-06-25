import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const city = searchParams.get('city')
    const limit = Math.min(parseInt(searchParams.get('limit') || '10'), 50)

    let query = supabaseServer
      .from('properties')
      .select('*')
      .eq('listing_status', 'active')
      .limit(limit)

    if (city) {
      query = query.eq('city', city)
    }

    const { data, error } = await query.order('created_at', {
      ascending: false,
    })

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get properties error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch properties' } },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    // Get authenticated user
    const authHeader = request.headers.get('authorization')
    if (!authHeader) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const body = await request.json()

    const { data, error } = await supabaseServer
      .from('properties')
      .insert({
        ...body,
        owner_id: 'user-id', // This should come from auth header in production
      })
      .select()

    if (error) {
      throw error
    }

    return NextResponse.json({ data }, { status: 201 })
  } catch (error) {
    console.error('Create property error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to create property' } },
      { status: 500 }
    )
  }
}
