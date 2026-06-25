import type { NextRequest } from 'next/server'
import { createServerClient } from '@supabase/ssr'


// Types mínimos para evitar errores por tipado aún no disponible en este repo.
// Si más adelante se agrega el tipo Database, se puede refinar.






// Nota: para que esto funcione, el proyecto debe tener configuradas variables
// NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY y SUPABASE_SERVICE_KEY.

export function createSupabaseServerClient(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  const serviceKey = process.env.SUPABASE_SERVICE_KEY

  if (!url || !anonKey) {
    throw new Error(
      'Missing Supabase env vars: NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_ANON_KEY'
    )
  }

  // Versión genérica (sin tipado interno de @supabase/ssr) para evitar errores de TS en este repo.
  return createServerClient(url, anonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll().map((c) => ({ name: c.name, value: c.value }))
      },
      setAll() {
        // En App Router, @supabase/ssr se encarga de la persistencia.
        // handler intencionalmente vacío.
      },

    },

    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
    global: {
      headers: serviceKey ? { Authorization: `Bearer ${serviceKey}` } : {},
    },
  })
}


export async function getUserFromRequest(request: NextRequest) {
  const supabase = createSupabaseServerClient(request)

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  return { user, error }
}

export async function requireAuth(request: NextRequest) {
  const { user, error } = await getUserFromRequest(request)
  if (error || !user) {
    return { user: null, error: error instanceof Error ? error : new Error('Unauthorized') }

  }
  return { user, error: null }
}


