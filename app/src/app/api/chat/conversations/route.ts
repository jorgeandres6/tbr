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
      .from('chat_conversations')
      .select('*')
      .or(`tenant_id.eq.${userId},owner_id.eq.${userId}`)
      .order('last_message_at', { ascending: false })

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get conversations error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch conversations' } },
      { status: 500 }
    )
  }
}
