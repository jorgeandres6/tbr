import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

// Cliente para operaciones del cliente (browser)
export const supabaseClient = createClient(supabaseUrl, supabaseAnonKey)

// Cliente para operaciones del servidor (API routes)
export const supabaseServer = createClient(
  supabaseUrl,
  supabaseServiceKey || supabaseAnonKey,
  {
    auth: {
      persistSession: false,
    },
  }
)

// Helper para obtener usuario autenticado
export async function getAuthUser() {
  const {
    data: { user },
  } = await supabaseClient.auth.getUser()
  return user
}

// Helper para obtener sesión
export async function getSession() {
  const {
    data: { session },
  } = await supabaseClient.auth.getSession()
  return session
}
