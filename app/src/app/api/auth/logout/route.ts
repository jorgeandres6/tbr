import { NextResponse } from 'next/server'

import { supabaseClient } from '@/lib/supabase'

export async function POST() {
  try {

    const { error } = await supabaseClient.auth.signOut()


    if (error) {
      return NextResponse.json(
        { error: { message: error.message } },
        { status: 400 }
      )
    }

    return NextResponse.json({
      data: { message: 'Logged out successfully' },
    })
  } catch (error) {
    console.error('Logout error:', error)
    return NextResponse.json(
      { error: { message: 'Internal server error' } },
      { status: 500 }
    )
  }
}
