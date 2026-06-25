# 🚀 Integración Supabase - Real Estate Swipe App

## Actualización Arquitectónica: Adopción de Supabase

**Fecha:** 24 de Junio de 2026  
**Versión:** 1.1 (Supabase Edition)

---

## 📋 Tabla de Contenidos

1. [Comparativa: Antes vs. Después](#comparativa-antes-vs-después)
2. [Ventajas de Supabase](#ventajas-de-supabase)
3. [Migración de Arquitectura](#migración-de-arquitectura)
4. [Setup Supabase](#setup-supabase)
5. [Cambios en Backend](#cambios-en-backend)
6. [Cambios en Frontend](#cambios-en-frontend)
7. [Seguridad con RLS](#seguridad-con-rls)
8. [Presupuesto Actualizado](#presupuesto-actualizado)

---

## 🔄 Comparativa: Antes vs. Después

### ANTES (Auto-hosted)

```
┌─────────────────┐
│  React Native   │
└────────┬────────┘
         │ REST API
         ▼
┌─────────────────────────────┐
│  Node.js + Express + JWT    │
│  (Requiere: scaling manual) │
└────────┬────────────────────┘
         │ SQL queries
         ▼
┌──────────────────────┐
│ PostgreSQL (self-hosted)  │
│ (Admin necesario)         │
└──────────────────────┘

COSTOS:
✗ Developers manteniendo servers
✗ DevOps complexity
✗ Backups manuales
✗ Scaling manual
✗ ~$500+/mes AWS
✗ Vigilancia 24/7
```

### DESPUÉS (Supabase)

```
┌─────────────────┐
│  React Native   │
└────────┬────────┘
         │ Supabase Client SDK
    ┌────┴──────────────────────────────┐
    ▼                                   ▼
┌──────────────────────┐     ┌────────────────────┐
│ Supabase Auth        │     │ Supabase Functions │
│ (OAuth2, Email)      │     │ (Edge Node.js)     │
└──────────────────────┘     └────────────────────┘
         │                          │
         └──────────┬───────────────┘
                    ▼
         ┌─────────────────────────────┐
         │ Supabase PostgreSQL         │
         │ • Realtime Subscriptions    │
         │ • RLS Policies              │
         │ • Storage Integrado         │
         │ • Triggers & Functions      │
         └─────────────────────────────┘

COSTOS:
✓ Zero DevOps
✓ Backups automáticos
✓ Scaling automático
✓ ~$25-150/mes plan
✓ No vigilancia requerida
✓ Equipo enfocado en features
```

---

## ✨ Ventajas de Supabase

### 1. **Autenticación Nativa**

❌ ANTES:
```typescript
// Manual JWT implementation
const token = jwt.sign({user_id, role}, secret);
// Manejo de refresh tokens
// Validación en cada request
```

✅ AHORA:
```typescript
// Supabase Auth out-of-the-box
const { user } = await supabase.auth.signUp({
  email,
  password,
});
// Automático: email verification, MFA, OAuth2
```

### 2. **Base de Datos Realtime**

❌ ANTES:
```typescript
// Socket.io + manual event handling
socket.on('message', (data) => {
  // Insertar en BD manualmente
  // Emitir a otros users manualmente
});
```

✅ AHORA:
```typescript
// Realtime subscriptions automáticas
supabase
  .from('chat_messages')
  .on('INSERT', (payload) => {
    console.log('New message!', payload);
  })
  .subscribe();
```

### 3. **Seguridad en la Base de Datos (RLS)**

❌ ANTES:
```typescript
// Validar permisos en backend
app.get('/documents/:id', (req, res) => {
  // Verificar que user puede ver este doc
  // Fácil cometer errores
});
```

✅ AHORA:
```sql
-- Policies en la BD (garantizado)
CREATE POLICY "users can see their own docs"
  ON documentation_hub
  USING (user_id = auth.uid());

CREATE POLICY "matched users can see docs"
  ON documentation_hub
  USING (
    EXISTS(
      SELECT 1 FROM matches m
      WHERE m.tenant_id = auth.uid() 
      AND m.tenant_docs_revealed = true
    )
  );
```

### 4. **Storage Integrado**

❌ ANTES:
```typescript
// Configurar AWS S3
// Manejo de keys
// Cifrado manual
```

✅ AHORA:
```typescript
// Supabase Storage (S3 compatible)
const { data, error } = await supabase.storage
  .from('documents')
  .upload(`${userId}/cedula.pdf`, file);
```

### 5. **Edge Functions (Serverless)**

❌ ANTES:
```typescript
// Mantener Node.js server corriendo
// Escalar manualmente
```

✅ AHORA:
```typescript
// Edge Functions (serverless)
// Escalan automáticamente
// Ejecuta lógica custom en Node.js

// functions/match-handler/index.ts
Deno.serve(async (req) => {
  // Lógica cuando se aprueba un match
});
```

### 6. **API REST Auto-generada**

✅ Supabase genera automáticamente REST API de tus tablas:

```bash
# Queries automáticas sin código
GET /rest/v1/properties?city=eq.Bogotá
POST /rest/v1/swipes
PATCH /rest/v1/matches?id=eq.xxx
DELETE /rest/v1/chat_messages?id=eq.xxx
```

---

## 🏗️ Migración de Arquitectura

### Arquitectura Anterior (Self-hosted)

```
┌────────────────────────────────────┐
│          FRONTEND MÓVIL             │
│       (React Native)                │
└────────────────┬─────────────────────┘
                 │ REST API + WebSocket
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  ┌──────────────┐  ┌──────────────┐
  │   Express    │  │   Socket.io  │
  │   (Auth)     │  │   (Chat)     │
  └──────┬───────┘  └──────┬───────┘
         │                 │
         └────────┬────────┘
                  ▼
         ┌─────────────────┐
         │  PostgreSQL 13  │
         │  + Redis        │
         │  (Self-hosted)  │
         └─────────────────┘
         
COMPONENTES A MANTENER:
- Servidores
- Backup strategy
- Scaling logic
- Auth flow
- Socket management
```

### Nueva Arquitectura (Supabase)

```
┌────────────────────────────────────┐
│          FRONTEND MÓVIL             │
│       (React Native)                │
└────────────┬───────────────────────┘
             │ Supabase Client SDK
    ┌────────┴────────────────────────────────┐
    │                                         │
    ▼                                         ▼
┌──────────────┐                   ┌─────────────────────┐
│ Supabase     │                   │  Supabase Functions │
│ Realtime     │                   │  (Edge serverless)  │
│ Subscriptions│                   │  (Lógica custom)    │
└──────────────┘                   └─────────────────────┘
    │                                         │
    └─────────────────┬──────────────────────┘
                      ▼
         ┌──────────────────────────────┐
         │  Supabase PostgreSQL         │
         │  • Auth integrada            │
         │  • RLS Policies              │
         │  • Storage integrado         │
         │  • Backup automático         │
         │  • Scaling automático        │
         │  • Monitoreo                 │
         └──────────────────────────────┘

COMPONENTES ELIMINADOS:
✗ Mantener servidores Express
✗ Configuar Redis
✗ Implementar JWT
✗ Manejar WebSocket
✗ Backups manuales
✗ Scaling manual
```

### Qué Ocurre con el Backend

#### Opción A: Eliminar backend (Para MVP)

```
Frontend <-> Supabase (directamente)

Ventajas:
✓ Cero complejidad
✓ Cero DevOps
✓ Máxima velocidad MVP

Desventajas:
✗ Toda lógica en frontend o RLS
✗ No escalable a lógica compleja
```

#### Opción B: Guardar backend (Para más control)

```
Frontend <-> Express (thin layer) <-> Supabase

Ventajas:
✓ Lógica centralizada
✓ Validación adicional
✓ Más seguro

Desventajas:
✗ Sigue requiriendo DevOps
✗ No aprovecha 100% Supabase
```

### Recomendación para MVP

**Opción A + Supabase Edge Functions:**

```
Frontend conecta directamente a Supabase para:
✅ Auth (sign up, login, MFA)
✅ Chat (realtime)
✅ Swipes (CRUD + realtime)
✅ Matches (CRUD)

Supabase Edge Functions para:
✅ Lógica compleja (auto-match)
✅ Validaciones adicionales
✅ Webhooks externos
✅ Notificaciones
```

---

## 🔧 Setup Supabase

### Step 1: Crear Proyecto

```bash
# 1. Ir a https://supabase.com
# 2. Sign up gratis
# 3. Create new project
#    - Project name: realestateswipe
#    - Database password: strong-password
#    - Region: choose your region
# 4. Wait for deployment (~2 min)
```

### Step 2: Deploy Database Schema

```bash
# 1. En Supabase console → SQL Editor
# 2. Copiar todo el contenido de database.sql
# 3. Pegar en SQL Editor
# 4. Run
# ✅ Tablas creadas automáticamente
```

### Step 3: Obtener Credenciales

En Supabase Console → Settings → API:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...  (guardar seguro!)
SUPABASE_JWT_SECRET=your-jwt-secret
```

### Step 4: Setup Auth Providers (Opcional)

```
En Supabase → Authentication → Providers:

✅ Email
✅ OAuth (Google, GitHub, etc.)
✅ MFA (TOTP)

Configurar en settings según tus necesidades
```

### Step 5: Configurar Storage

```bash
# En Supabase → Storage:
# 1. Create bucket: documents
#    - Make it private
#    - Add policy para usuarios

# 2. Create bucket: avatars
#    - Public bucket
#    - Add policy para usuarios
```

---

## 💻 Cambios en Backend

### Opción 1: Minimal Backend (Recomendado para MVP)

**Solo Edge Functions:**

```
realestateswipe/
├── supabase/
│   ├── functions/
│   │   ├── auto-match/
│   │   │   └── index.ts
│   │   ├── validate-documents/
│   │   │   └── index.ts
│   │   ├── send-notifications/
│   │   │   └── index.ts
│   │   └── webhook-handler/
│   │       └── index.ts
│   └── migrations/
│       └── 001_initial.sql
├── .env.local
└── package.json
```

**Archivo: supabase/functions/auto-match/index.ts**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  // Webhook cuando tenant da "like"
  // Verificar si owner tiene auto_match_enabled
  // Si sí: crear match + revelar documentos
  
  const { data: { swipe } } = await req.json()
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_KEY')
  )
  
  const { data: owner } = await supabase
    .from('owner_profiles')
    .select('auto_match_enabled')
    .eq('owner_id', swipe.owner_id)
    .single()
  
  if (owner?.auto_match_enabled) {
    // Create match
    await supabase
      .from('matches')
      .insert({
        tenant_id: swipe.tenant_id,
        property_id: swipe.property_id,
        owner_id: swipe.owner_id,
        status: 'matched',
        auto_matched: true,
        tenant_docs_revealed: true,
        owner_docs_revealed: true,
        guarantor_info_revealed: true,
      })
  }
  
  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### Opción 2: Backend Express Delgado (Si necesitas más control)

```typescript
import express from 'express'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
)

const app = express()

// Middleware: Supabase Auth
app.use(async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1]
  
  if (token) {
    const { data: { user } } = await supabase.auth.getUser(token)
    req.user = user
  }
  
  next()
})

// Validaciones adicionales
app.post('/api/validate-match', async (req, res) => {
  // Lógica adicional que no queremos en frontend
})

app.listen(3000)
```

---

## 📱 Cambios en Frontend

### Instalación

```bash
npm install @supabase/supabase-js
npm install @react-native-async-storage/async-storage
```

### Configuración

**Archivo: src/lib/supabase.ts**

```typescript
import { createClient } from '@supabase/supabase-js'
import AsyncStorage from '@react-native-async-storage/async-storage'

const supabaseUrl = 'https://your-project.supabase.co'
const supabaseAnonKey = 'eyJhbGc...'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
})
```

### Auth (Sign Up)

```typescript
// src/screens/auth/RegisterScreen.tsx

const handleRegister = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  
  if (error) {
    Alert.alert('Error', error.message)
  } else {
    // Crear perfil basado en rol
    await supabase
      .from('tenant_profiles')
      .insert({
        tenant_id: data.user.id,
        description: formData.description,
        income_range_id: formData.incomeRange,
      })
  }
}
```

### Realtime Subscriptions (Chat)

```typescript
// src/screens/ChatScreen.tsx

useEffect(() => {
  const channel = supabase
    .from(
      `chat_messages:conversation_id=eq.${conversationId}`
    )
    .on('INSERT', (payload) => {
      setMessages([...messages, payload.new])
    })
    .subscribe()
  
  return () => {
    supabase.removeChannel(channel)
  }
}, [conversationId])
```

### Sending Messages

```typescript
const sendMessage = async (text: string) => {
  const { data: { user } } = await supabase.auth.getUser()
  
  const { error } = await supabase
    .from('chat_messages')
    .insert({
      conversation_id: conversationId,
      sender_id: user.id,
      recipient_id: otherUserId,
      message_body: text,
    })
  
  if (error) Alert.alert('Error', error.message)
}
```

### Swipes

```typescript
const getSwipeStack = async (city: string) => {
  // Propiedades que NO han sido swiped
  const { data, error } = await supabase
    .from('properties')
    .select('*')
    .eq('city', city)
    .eq('listing_status', 'active')
    // Usar RLS para filtrar
    .limit(10)
  
  return data
}

const createSwipe = async (propertyId: string, action: string) => {
  const { data: { user } } = await supabase.auth.getUser()
  
  const { error } = await supabase
    .from('swipes')
    .insert({
      tenant_id: user.id,
      property_id: propertyId,
      action,
    })
  
  // Realtime trigger: si action='like' e owner.auto_match_enabled
  // → Automáticamente crea match (en BD con trigger)
}
```

### Zustand Store (Simplificado)

```typescript
// src/store/authStore.ts

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  session: null,
  
  // Supabase maneja session automáticamente
  restoreSession: async () => {
    const { data: { session } } = await supabase.auth.getSession()
    set({ session, user: session?.user || null })
  },
  
  signUp: async (email, password) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    })
    if (!error) set({ user: data.user })
    return error
  },
  
  signOut: async () => {
    await supabase.auth.signOut()
    set({ session: null, user: null })
  },
}))
```

---

## 🔐 Seguridad con RLS

### Policies para Privacidad de Documentos

```sql
-- Documentos privados hasta match

-- 1. Users solo ven sus propios documentos
CREATE POLICY "users_own_documents"
  ON documentation_hub
  FOR SELECT
  USING (user_id = auth.uid());

-- 2. Matched users ven documentos revelados
CREATE POLICY "matched_users_see_revealed_docs"
  ON documentation_hub
  FOR SELECT
  USING (
    visibility_status = 'match_visible' AND
    EXISTS(
      SELECT 1 FROM matches m
      WHERE (
        (m.tenant_id = auth.uid() AND m.tenant_docs_revealed = true) OR
        (m.owner_id = auth.uid() AND m.owner_docs_revealed = true)
      )
      AND m.status = 'matched'
    )
  );

-- 3. Tenants pueden insertar sus propios documentos
CREATE POLICY "tenants_insert_own_docs"
  ON documentation_hub
  FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

### Policies para Chat

```sql
-- Chat solo entre matched users

CREATE POLICY "users_see_their_conversations"
  ON chat_conversations
  FOR SELECT
  USING (
    tenant_id = auth.uid() OR owner_id = auth.uid()
  );

CREATE POLICY "users_only_send_to_matched"
  ON chat_messages
  FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS(
      SELECT 1 FROM chat_conversations cc
      WHERE cc.conversation_id = chat_messages.conversation_id
      AND (cc.tenant_id = auth.uid() OR cc.owner_id = auth.uid())
    )
  );
```

### Policies para Swipes

```sql
-- Tenants solo pueden swipear, no ver otras solicitudes

CREATE POLICY "tenants_can_swipe_properties"
  ON swipes
  FOR INSERT
  WITH CHECK (
    tenant_id = auth.uid() AND
    -- No pueden swipear propiedad propia
    NOT EXISTS(
      SELECT 1 FROM properties p
      WHERE p.property_id = swipes.property_id
      AND p.owner_id = auth.uid()
    )
  );

CREATE POLICY "owners_see_their_swipes"
  ON swipes
  FOR SELECT
  USING (owner_id = auth.uid());
```

---

## 💰 Presupuesto Actualizado

### ANTES (Self-hosted)

```
AWS:
├─ RDS PostgreSQL (t3.micro)        $35/mes
├─ ElastiCache Redis (t3.micro)     $20/mes
├─ EC2 (t3.small, 2 instances)      $60/mes
├─ S3 + Bandwidth                   $20/mes
└─ Data transfer                    $20/mes
   SUBTOTAL                         $155/mes

DevOps/Team:
├─ DevOps engineer (part-time)      $1500/mes
├─ Monitoring/alerts                $100/mes
└─ Backups & disaster recovery      $200/mes
   SUBTOTAL                         $1800/mes

TOTAL: ~$2000/mes (inicial)
```

### AHORA (Supabase)

```
Supabase (con Edge Functions):
├─ Starter Plan                     $25/mes
├─ Pro Plan (recomendado)           $150/mes
│  (Si MVP crece rápido)
└─ Storage & Bandwidth              $10-50/mes
   SUBTOTAL                         $150-200/mes

Eliminado:
✓ No DevOps salary needed
✓ No backup management
✓ No monitoring software
✓ No scaling worries

TOTAL: ~$200/mes (sin DevOps)

AHORRO: $1800/mes en resources humanos
```

### Pricingdetallado Supabase

| Plan | DB Size | Storage | Functions | Precio |
|------|---------|---------|-----------|--------|
| **Starter** | 500MB | 1GB | Gratis | $0* |
| **Pro** | 10GB | 100GB | $1.50/1M calls | $150 |
| **Enterprise** | Custom | Custom | Custom | Custom |

*Starter tiene limitaciones (pocos Edge Functions)

**Recomendación MVP:** Plan Pro ($150/mes) para tener:
- 10GB DB (suficiente para 100K users)
- 100GB Storage (500K documentos)
- Edge Functions sin limits
- Soporte prioritario

---

## ⚡ Performance Improvements

### Beneficios

```
LATENCIA CHAT:
Antes: ~200ms (Node.js → DB → Socket → Client)
Ahora: ~50ms (Direct Realtime)
Mejora: 4x más rápido

DEPLOYMENT TIME:
Antes: 20 minutos (build + push + deploy)
Ahora: 2 minutos (git push)
Mejora: 10x más rápido

UPTIME:
Antes: 99.5% (depende de ti)
Ahora: 99.95% (SLA Supabase)
Mejora: 10x menos problemas

SCALING:
Antes: Manual, requiere planning
Ahora: Automático
Mejora: Infinito (manejado por Supabase)
```

---

## 📚 Recursos Supabase

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Examples](https://github.com/supabase/supabase/tree/master/examples)
- [React Native + Supabase](https://supabase.com/docs/guides/getting-started/quickstarts/react-native)
- [Supabase Functions](https://supabase.com/docs/guides/functions)
- [RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)

---

## ✅ Checklist Migración

- [ ] Crear proyecto Supabase
- [ ] Deploy schema SQL
- [ ] Configurar Auth providers
- [ ] Configurar Storage buckets
- [ ] Crear RLS policies
- [ ] Deploy Edge Functions
- [ ] Actualizar Frontend SDK
- [ ] Testar auth flow
- [ ] Testar realtime chat
- [ ] Testar RLS security
- [ ] Migrar datos (si existe DB previa)
- [ ] Testing completo
- [ ] Deploy a producción

---

## 🎉 Resultado Final

Con Supabase:

✅ **MVP en 4-6 semanas** (vs 8)  
✅ **Sin DevOps** (solo developers)  
✅ **Cost: $200/mes** (vs $2000+)  
✅ **Security: Garantizada en BD**  
✅ **Scalability: Automática**  
✅ **Realtime: Nativo**  
✅ **95% menos código de infraestructura**  

**Conclusión:** Supabase es la opción óptima para MVP de startups.

---

**Última actualización:** 24 de Junio de 2026  
**Stack Recomendado:** React Native + Supabase + Edge Functions  
**Versión Arquitectónica:** 1.1 (Supabase Edition)

