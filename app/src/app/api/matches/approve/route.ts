import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  try {
    const userId = request.headers.get('x-user-id')
    const { searchParams } = new URL(request.url)
    const matchId = searchParams.get('id')

    if (!userId || !matchId) {
      return NextResponse.json(
        { error: { message: 'Missing parameters' } },
        { status: 400 }
      )
    }

    // Verify user is owner
    const { data: match } = await supabaseServer
      .from('matches')
      .select('*')
      .eq('match_id', matchId)
      .single()

    if (!match || match.owner_id !== userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 403 }
      )
    }

    // Update match status
    const { data, error } = await supabaseServer
      .from('matches')
      .update({
        status: 'matched',
        owner_docs_revealed: true,
        tenant_docs_revealed: true,
      })
      .eq('match_id', matchId)
      .select()

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Approve match error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to approve match' } },
      { status: 500 }
    )
  }
}
