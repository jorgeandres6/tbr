import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { z } from 'zod'

const tenantProfileSchema = z.object({
  description: z.string(),
  income_range_id: z.string(),
  occupation: z.string(),
})

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
      .from('tenant_profiles')
      .select('*')
      .eq('tenant_id', userId)
      .single()

    if (error && error.code !== 'PGRST116') {
      throw error
    }

    return NextResponse.json({ data })
  } catch (error) {
    console.error('Get tenant profile error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to fetch profile' } },
      { status: 500 }
    )
  }
}

export async function PUT(request: NextRequest) {
  try {
    const userId = request.headers.get('x-user-id')

    if (!userId) {
      return NextResponse.json(
        { error: { message: 'Unauthorized' } },
        { status: 401 }
      )
    }

    const body = await request.json()
    const profile = tenantProfileSchema.parse(body)

    const { data, error } = await supabaseServer
      .from('tenant_profiles')
      .upsert(
        {
          tenant_id: userId,
          ...profile,
        },
        { onConflict: 'tenant_id' }
      )
      .select()

    if (error) {
      throw error
    }

    // Mark profile as completed
    await supabaseServer
      .from('users')
      .update({ profile_completed: true })
      .eq('user_id', userId)

    return NextResponse.json({ data })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: { message: 'Invalid input' } },
        { status: 400 }
      )
    }

    console.error('Update tenant profile error:', error)
    return NextResponse.json(
      { error: { message: 'Failed to update profile' } },
      { status: 500 }
    )
  }
}
