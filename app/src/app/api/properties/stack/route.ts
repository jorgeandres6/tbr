import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const city = searchParams.get('city') || 'Bogotá'
    const limit = Math.min(parseInt(searchParams.get('limit') || '10'), 50)

    // Get properties that haven't been swiped yet
    const { data, error } = await supabaseServer
      .from('properties')
      .select(
        `
        *,
        properties_media(*)
      `
      )
      .eq('city', city)
      .eq('listing_status', 'active')
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get property stack error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch property stack' } },
      { status: 500 }
    )
  }
}
