import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { z } from 'zod'

const messageSchema = z.object({
  message_body: z.string().min(1),
})

type ChatIdContext = { params: Promise<{ id: string }> }

export async function GET(
  request: NextRequest,
  context: ChatIdContext
) {
  try {
    const userId = request.headers.get('x-user-id')
    const { id } = await context.params
    const conversationId = id

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const { data, error } = await supabaseServer
      .from('chat_messages')
      .select('*')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })

    if (error) {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get messages error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch messages' } },
      { status: 500 }
    )
  }
}

export async function POST(
  request: NextRequest,
  context: ChatIdContext
) {
  try {
    const userId = request.headers.get('x-user-id')
    const { id } = await context.params
    const conversationId = id

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const body = await request.json()
    const { message_body } = messageSchema.parse(body)

    // Get conversation to find recipient
    const { data: conversation } = await supabaseServer
      .from('chat_conversations')
      .select('*')
      .eq('conversation_id', conversationId)
      .single()

    if (!conversation) {
      return NextResponse.json(
        { error: { message: 'Conversation not found' } },
        { status: 404 }
      )
    }

    const recipientId =
      conversation.tenant_id === userId
        ? conversation.owner_id
        : conversation.tenant_id

    const { data, error } = await supabaseServer
      .from('chat_messages')
      .insert({
        conversation_id: conversationId,
        sender_id: userId,
        recipient_id: recipientId,
        message_body,
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

    console.error('Send message error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to send message' } },
      { status: 500 }
    )
  }
}

