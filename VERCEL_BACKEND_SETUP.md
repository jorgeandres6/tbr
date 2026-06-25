# 🚀 Vercel Backend Setup - Real Estate Swipe

**Backend serverless en Vercel + Supabase**

---

## 📋 Tabla de Contenidos

1. [Arquitectura Vercel](#arquitectura-vercel)
2. [Setup Inicial](#setup-inicial)
3. [Serverless Functions](#serverless-functions)
4. [Integración con Supabase](#integración-con-supabase)
5. [Ejemplos de Código](#ejemplos-de-código)
6. [Deployment](#deployment)
7. [Monitoreo](#monitoreo)

---

## 🏗️ Arquitectura Vercel

### Stack Completo

```
┌─────────────────────────────────────────────┐
│         Frontend (Next.js / React)          │
│    Hosted en: Vercel (mismo proyecto)       │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────────────┐
        │                         │
        ▼                         ▼
┌──────────────────┐     ┌──────────────────┐
│ Vercel Functions │     │ Supabase SDK     │
│ (Backend Logic)  │     │ (Realtime Chat)  │
└────────┬─────────┘     └──────┬───────────┘
         │                      │
         └──────────┬───────────┘
                    ▼
         ┌──────────────────────┐
         │ Supabase PostgreSQL  │
         │ • Auth               │
         │ • Database           │
         │ • Storage            │
         │ • Realtime           │
         └──────────────────────┘
```

### Ventajas de Vercel + Supabase

```
✅ Frontend & Backend en mismo lugar
✅ Deploy automático con git push
✅ Environment variables centralizadas
✅ Serverless functions escalables
✅ Zero server management
✅ CDN global automático
✅ SSL/TLS gratuito
✅ Logs y monitoreo integrados
✅ Integración perfecta con Next.js
```

---

## 🔧 Setup Inicial

### 1. Crear Proyecto Next.js

```bash
npx create-next-app@latest realestateswipe --typescript

# Opciones:
# ✓ TypeScript: Yes
# ✓ ESLint: Yes
# ✓ Tailwind: Yes (opcional)
# ✓ App router: Yes
```

### 2. Estructura de Carpetas

```
realestateswipe/
├── app/
│   ├── page.tsx          (Frontend: Home)
│   ├── login/
│   │   └── page.tsx      (Frontend: Login)
│   ├── swipe/
│   │   └── page.tsx      (Frontend: Swipe)
│   ├── chat/
│   │   └── page.tsx      (Frontend: Chat)
│   └── layout.tsx
│
├── api/                  ⭐ BACKEND
│   ├── auth/
│   │   └── route.ts      (Auth logic)
│   ├── properties/
│   │   └── route.ts      (Properties CRUD)
│   ├── swipes/
│   │   └── route.ts      (Swipe logic)
│   ├── matches/
│   │   └── route.ts      (Match logic)
│   ├── chat/
│   │   └── route.ts      (Chat)
│   └── webhooks/
│       └── route.ts      (Supabase webhooks)
│
├── lib/
│   ├── supabase.ts       (Supabase client)
│   ├── api-client.ts     (API helper)
│   └── types.ts          (TypeScript types)
│
├── public/
├── .env.local            (Secrets)
├── tsconfig.json
├── next.config.js
└── package.json
```

### 3. Instalar Dependencias

```bash
npm install @supabase/supabase-js
npm install @supabase/ssr         # Para SSR auth
npm install zod                   # Validación
npm install next-auth             # Auth (opcional)
```

### 4. Variables de Entorno

**Archivo: .env.local**

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...  # Solo backend

# App
NEXT_PUBLIC_API_URL=http://localhost:3000
NODE_ENV=development
```

---

## ⚙️ Serverless Functions

### Qué son Vercel Functions

```typescript
// api/hello/route.ts - Automáticamente un endpoint
// URL: /api/hello

import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  return NextResponse.json({ message: 'Hello!' })
}

export async function POST(request: NextRequest) {
  const data = await request.json()
  return NextResponse.json({ received: data })
}
```

### Características

```
✅ Escalabilidad automática
✅ Ejecución en edge (bajo latency)
✅ Timeout: 10 segundos (Hobby) / 60 segundos (Pro)
✅ Memoria: 512MB
✅ Logs automáticos en Vercel dashboard
✅ CORS manejado automáticamente
✅ Env vars disponibles automáticamente
```

---

## 🔗 Integración con Supabase

### Cliente Supabase en Backend

**Archivo: lib/supabase.ts**

```typescript
import { createClient } from '@supabase/supabase-js'

// Cliente para operaciones del servidor
export const supabaseServer = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!,  // Service key = full access
  {
    auth: {
      persistSession: false,  // No need session in serverless
    },
  }
)

// Cliente para operaciones del cliente
export const supabaseClient = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

### Auth Middleware

**Archivo: lib/auth.ts**

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'

export async function getSession(request: NextRequest) {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          const response = NextResponse.next()
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          )
          return response
        },
      },
    }
  )

  const {
    data: { user },
  } = await supabase.auth.getUser()

  return user
}

export async function withAuth(
  handler: (req: NextRequest, user: any) => Promise<Response>
) {
  return async (request: NextRequest) => {
    const user = await getSession(request)

    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    return handler(request, user)
  }
}
```

---

## 💻 Ejemplos de Código

### 1. Endpoint: Crear Swipe

**Archivo: api/swipes/route.ts**

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { withAuth } from '@/lib/auth'

async function POST(request: NextRequest, user: any) {
  try {
    const { property_id, action } = await request.json()

    // Validar que no sea propio property
    const { data: property } = await supabaseServer
      .from('properties')
      .select('owner_id')
      .eq('property_id', property_id)
      .single()

    if (property?.owner_id === user.id) {
      return NextResponse.json(
        { error: 'Cannot swipe own property' },
        { status: 400 }
      )
    }

    // Crear swipe
    const { data, error } = await supabaseServer
      .from('swipes')
      .insert({
        tenant_id: user.id,
        property_id,
        action, // 'like' | 'dislike' | 'later'
      })
      .select()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error creating swipe:', error)
    return NextResponse.json(
      { error: 'Failed to create swipe' },
      { status: 500 }
    )
  }
}

// Este es ahora un middleware protegido
export const POST = withAuth(POST)
```

### 2. Endpoint: Obtener Stack de Propiedades

**Archivo: api/properties/stack/route.ts**

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { withAuth } from '@/lib/auth'

async function GET(request: NextRequest, user: any) {
  try {
    const { searchParams } = new URL(request.url)
    const city = searchParams.get('city')
    const limit = parseInt(searchParams.get('limit') || '10')

    // Propiedades que NO han sido swiped por este usuario
    const { data, error } = await supabaseServer
      .from('properties')
      .select('*')
      .eq('city', city)
      .eq('listing_status', 'active')
      // Properties NOT swiped
      .not(
        'property_id',
        'in',
        `(
          SELECT property_id FROM swipes 
          WHERE tenant_id = '${user.id}'
        )`
      )
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching stack:', error)
    return NextResponse.json(
      { error: 'Failed to fetch properties' },
      { status: 500 }
    )
  }
}

export const GET = withAuth(GET)
```

### 3. Endpoint: Validación y Auto-match

**Archivo: api/matches/validate/route.ts**

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'
import { withAuth } from '@/lib/auth'
import { z } from 'zod'

const matchSchema = z.object({
  match_id: z.string(),
})

async function POST(request: NextRequest, user: any) {
  try {
    const body = await request.json()
    const { match_id } = matchSchema.parse(body)

    // Get match details
    const { data: match, error: matchError } = await supabaseServer
      .from('matches')
      .select('*')
      .eq('match_id', match_id)
      .single()

    if (matchError) throw matchError

    // Verify user is owner of property
    const { data: property } = await supabaseServer
      .from('properties')
      .select('owner_id')
      .eq('property_id', match.property_id)
      .single()

    if (property?.owner_id !== user.id) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 403 }
      )
    }

    // Validate tenant documentation
    const { data: docs } = await supabaseServer
      .from('documentation_hub')
      .select('*')
      .eq('user_id', match.tenant_id)
      .eq('visibility_status', 'private')

    if (!docs || docs.length === 0) {
      return NextResponse.json(
        { error: 'Tenant has no documentation' },
        { status: 400 }
      )
    }

    return NextResponse.json({
      valid: true,
      documentation_count: docs.length,
    })
  } catch (error) {
    console.error('Validation error:', error)
    return NextResponse.json(
      { error: 'Validation failed' },
      { status: 400 }
    )
  }
}

export const POST = withAuth(POST)
```

### 4. Webhook: Auto-match Handler

**Archivo: api/webhooks/auto-match/route.ts**

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  try {
    // Verify Supabase webhook signature
    const signature = request.headers.get('x-supabase-signature')
    // Implement verification if needed

    const payload = await request.json()

    if (payload.type === 'INSERT' && payload.table === 'swipes') {
      const swipe = payload.record

      // If action is 'like', check owner's auto_match setting
      if (swipe.action === 'like') {
        const { data: owner } = await supabaseServer
          .from('owner_profiles')
          .select('auto_match_enabled')
          .eq('owner_id', swipe.owner_id)
          .single()

        if (owner?.auto_match_enabled) {
          // Auto-create match
          await supabaseServer.from('matches').insert({
            tenant_id: swipe.tenant_id,
            property_id: swipe.property_id,
            owner_id: swipe.owner_id,
            status: 'matched',
            auto_matched: true,
            tenant_docs_revealed: true,
            owner_docs_revealed: true,
          })

          // Send notification
          console.log(`Auto-matched: ${swipe.tenant_id} with property`)
        }
      }
    }

    return NextResponse.json({ ok: true })
  } catch (error) {
    console.error('Webhook error:', error)
    return NextResponse.json(
      { error: 'Webhook failed' },
      { status: 500 }
    )
  }
}
```

### 5. API Client Hook (Frontend)

**Archivo: lib/api-client.ts**

```typescript
export const apiClient = {
  async createSwipe(propertyId: string, action: string) {
    const res = await fetch('/api/swipes', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ property_id: propertyId, action }),
    })
    if (!res.ok) throw new Error(await res.text())
    return res.json()
  },

  async getPropertyStack(city: string, limit = 10) {
    const res = await fetch(
      `/api/properties/stack?city=${city}&limit=${limit}`
    )
    if (!res.ok) throw new Error(await res.text())
    return res.json()
  },

  async validateMatch(matchId: string) {
    const res = await fetch('/api/matches/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ match_id: matchId }),
    })
    if (!res.ok) throw new Error(await res.text())
    return res.json()
  },
}

// Uso en componentes:
// const stack = await apiClient.getPropertyStack('Bogotá')
```

---

## 🚀 Deployment

### Opción 1: Vercel CLI (Manual)

```bash
npm install -g vercel

# Deploy
vercel

# Deploy a producción
vercel --prod
```

### Opción 2: GitHub Integration (Recomendado)

```bash
# 1. Push código a GitHub
git add .
git commit -m "Initial commit"
git push origin main

# 2. En Vercel dashboard:
#    - Conectar GitHub account
#    - Seleccionar repositorio
#    - Deploy automático en cada push
```

### Opción 3: Vercel Dashboard

```
1. Ir a vercel.com
2. Login / Sign up
3. New Project
4. Import Git Repository
5. Configurar environment variables
6. Deploy
```

### Environment Variables en Vercel

```
Vercel Dashboard → Settings → Environment Variables

NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
NEXT_PUBLIC_API_URL=https://your-domain.vercel.app
```

---

## 📊 Monitoreo

### Logs en Vercel

```
Vercel Dashboard → Deployments → Logs

- View function logs
- View build logs
- Real-time streaming
```

### Error Tracking (Opcional)

**Instalar Sentry:**

```bash
npm install @sentry/nextjs
```

**Archivo: next.config.js**

```javascript
const withSentry = require('@sentry/nextjs')

module.exports = withSentry({
  reactStrictMode: true,
})
```

### Métricas

```
En Vercel Dashboard:
✅ Request count
✅ Function duration
✅ Error rate
✅ Edge compute time
✅ Bandwidth usage
```

---

## 📈 Performance Tips

### 1. Response Caching

```typescript
export async function GET(request: NextRequest) {
  const response = NextResponse.json(data)

  // Cache for 1 hour
  response.headers.set('Cache-Control', 'max-age=3600')

  return response
}
```

### 2. Database Connection Pooling

```typescript
// Vercel proporciona automaticamente connection pooling
// No requiere configuración extra
```

### 3. Middleware para Compresión

```typescript
export const config = {
  matcher: '/api/:path*',
}

// Next.js comprime automáticamente
```

---

## 🔐 Security

### CORS Headers

```typescript
const response = NextResponse.json(data)

response.headers.set('Access-Control-Allow-Origin', '*')
response.headers.set('Access-Control-Allow-Methods', 'GET, POST')

return response
```

### Rate Limiting

```typescript
// Implementar con middleware
import { Ratelimit } from '@upstash/ratelimit'

const ratelimit = new Ratelimit({
  redis: process.env.UPSTASH_REDIS_REST_URL,
  limiter: Ratelimit.slidingWindow(10, '1 h'),
})

export async function POST(request: NextRequest) {
  const { success } = await ratelimit.limit(user.id)

  if (!success) {
    return NextResponse.json(
      { error: 'Rate limited' },
      { status: 429 }
    )
  }

  // Procesar request
}
```

---

## 🎯 Checklist de Setup

- [ ] Crear proyecto Next.js
- [ ] Instalar Supabase SDK
- [ ] Crear estructura de carpetas
- [ ] Setup variables de entorno
- [ ] Crear cliente Supabase
- [ ] Crear middleware de auth
- [ ] Implementar primeros endpoints
- [ ] Deployar a Vercel
- [ ] Configurar webhook de Supabase
- [ ] Setup monitoreo y logs
- [ ] Testar endpoints
- [ ] Deploy a producción

---

## 📞 Troubleshooting

### Error: "SUPABASE_SERVICE_KEY is undefined"

```
Solución: Verificar .env.local incluye SUPABASE_SERVICE_KEY
Verificar variables en Vercel Dashboard
```

### Error: "Unauthorized" en API

```
Solución: Verificar token de Supabase es válido
Verificar withAuth middleware está en la función
```

### Timeout en función

```
Solución: Quebrar en múltiples funciones
Usar background jobs para operaciones largas
```

---

## 🎓 Recursos

- [Next.js Docs](https://nextjs.org/docs)
- [Vercel Functions](https://vercel.com/docs/functions/serverless-functions)
- [Vercel + Supabase](https://vercel.com/templates/next.js/supabase)
- [Supabase SSR](https://supabase.com/docs/guides/auth/auth-helpers/nextjs)

---

## ✅ Summary

```
Frontend + Backend en Vercel:
✓ Same repository
✓ Automatic deployment
✓ Zero server management
✓ Serverless functions
✓ Environment variables
✓ Logs and monitoring

Database: Supabase
✓ Managed PostgreSQL
✓ Auth integrated
✓ Realtime subscriptions
✓ Storage included

Result: 
✓ Simplest possible setup
✓ Maximum productivity
✓ Minimum operational overhead
```

**Recomendación:** Este es el stack PERFECTO para MVP. Úsalo.

---

**Stack Recomendado para MVP:**
- Frontend: Next.js (en Vercel)
- Backend: Vercel Functions (serverless)
- Database: Supabase
- Cost: $0-25/mes (Vercel hobby free, Supabase Pro $150/mes)

🚀 **Listo para comenzar!**
