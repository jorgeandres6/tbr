import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { z } from 'zod'

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['tenant', 'owner']),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, password, role } = signupSchema.parse(body)

    // Create auth user
    const { data: authData, error: authError } =
      await supabaseServer.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      })

    if (authError) {
      return NextResponse.json(
        { error: { message: authError.message } },
        { status: 400 }
      )
    }

    // Create user profile
    const { error: profileError } = await supabaseServer
      .from('users')
      .insert({
        user_id: authData.user.id,
        email,
        role,
        profile_completed: false,
      })

    if (profileError) {
      return NextResponse.json(
        { error: { message: 'Error creating profile' } },
        { status: 500 }
      )
    }

    return NextResponse.json({

      data: {
        user: authData.user,
        session: null,
      },
    })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: { message: 'Invalid input', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      )
    }

    console.error('Signup error:', error)
    return NextResponse.json(
      { error: { message: 'Internal server error' } },
      { status: 500 }
    )
  }
}
