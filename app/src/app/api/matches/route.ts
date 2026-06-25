import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function GET(request: NextRequest) {
  try {
    const userId = request.headers.get('x-user-id')

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const { data, error } = await supabaseServer
      .from('matches')
      .select('*')
      .or(`tenant_id.eq.${userId},owner_id.eq.${userId}`)
      .order('created_at', { ascending: false })

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get matches error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch matches' } },
      { status: 500 }
    )
  }
}
