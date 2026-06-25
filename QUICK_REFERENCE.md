# 🚀 Quick Reference - Vercel + Supabase Stack

**One-page cheat sheet for the MVP architecture**

---

## 📊 Architecture at a Glance

```
Next.js (Frontend + Backend)
       ↓
Vercel (Deploy)
       ↓
├─ Frontend Pages
├─ API Routes (Serverless)
└─ TypeScript Everywhere

        ↓

Supabase (Database + Auth + Realtime + Storage)
       ↓
├─ PostgreSQL (Data)
├─ Auth (Users)
├─ Realtime (Chat)
└─ Storage (Documents)
```

---

## 🎯 Quick Start (5 Steps)

```bash
# 1. Create Next.js project
npx create-next-app@latest realestateswipe --typescript

# 2. Install packages
npm install @supabase/supabase-js zod

# 3. Setup env
echo 'NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co' >> .env.local
echo 'SUPABASE_SERVICE_KEY=eyJhbGc...' >> .env.local

# 4. Create lib/supabase.ts (copy from VERCEL_BACKEND_SETUP.md)

# 5. Deploy
git push origin main  # Auto-deploys to Vercel
```

---

## 📁 Folder Structure (Minimal)

```
app/
├─ page.tsx              # Home
├─ swipe/
│   └─ page.tsx         # Swipe screen
└─ layout.tsx

api/
├─ auth/
│   └─ signup/route.ts  # Endpoint
├─ properties/
│   └─ route.ts         # Endpoint
└─ swipes/
    └─ route.ts         # Endpoint

lib/
├─ supabase.ts          # Client
└─ types.ts             # Types

.env.local              # Secrets
```

---

## 💻 Code Snippets

### Setup Supabase Client

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

export const supabaseServer = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
)
```

### Create API Endpoint

```typescript
// api/swipes/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { supabaseServer } from '@/lib/supabase'

export async function POST(request: NextRequest) {
  const { property_id, action } = await request.json()
  
  const { data, error } = await supabaseServer
    .from('swipes')
    .insert({ property_id, action })
  
  return NextResponse.json(data)
}
```

### Frontend Component

```typescript
// components/SwipeCard.tsx
'use client'

import { apiClient } from '@/lib/api-client'

export default function SwipeCard({ property }) {
  const handleSwipe = async (action: string) => {
    await apiClient.createSwipe(property.id, action)
  }

  return (
    <div>
      <h2>{property.title}</h2>
      <button onClick={() => handleSwipe('like')}>❤️ Like</button>
      <button onClick={() => handleSwipe('dislike')}>👎 Pass</button>
    </div>
  )
}
```

### Realtime Chat

```typescript
// Receive messages in real-time
supabase
  .from('chat_messages')
  .on('INSERT', (payload) => {
    console.log('New message:', payload.new)
  })
  .subscribe()
```

---

## 📍 Key Files to Know

| File | Purpose |
|------|---------|
| `lib/supabase.ts` | Supabase client setup |
| `api/[feature]/route.ts` | Backend endpoints |
| `app/[page]/page.tsx` | Frontend pages |
| `.env.local` | Environment secrets |
| `package.json` | Dependencies |

---

## 🔑 Environment Variables

```env
# Frontend (visible to browser)
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...

# Backend only (secrets)
SUPABASE_SERVICE_KEY=eyJhbGc...
```

---

## 🚀 Deployment

```bash
# Local development
npm run dev
# → http://localhost:3000

# Deploy to Vercel
git push origin main
# → Auto-deploys
# → https://your-project.vercel.app

# View logs
vercel logs
```

---

## 📊 Database Tables (12)

```
users (auth)
├─ tenant_profiles
├─ owner_profiles
├─ properties
├─ properties_media
├─ swipes
├─ matches
├─ chat_conversations
├─ chat_messages
├─ documentation_hub
├─ tenant_guarantors
└─ income_ranges
```

Import: Copy `database.sql` to Supabase SQL Editor

---

## 🔐 Security Basics

```typescript
// Verify user in API route
const { data: { user } } = await supabase.auth.getUser(token)
if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

// RLS automatically enforces user permissions
// Example: Only see own documents
// CREATE POLICY "Users see own docs"
//   ON documentation_hub
//   USING (user_id = auth.uid());
```

---

## 📈 Performance Metrics

```
Frontend: <1s (CDN)
API: <100ms (Edge function)
Chat: <50ms (Realtime)
Database: <50ms (Managed)
```

---

## 💰 Costs

```
Vercel:   $0-25/month
Supabase: $150/month
─────────────────────────
Total:    $150-175/month
```

vs Self-hosted: $500-2000/month (90% cheaper!)

---

## 🛠️ Useful Links

- [Next.js Docs](https://nextjs.org/docs)
- [Vercel Docs](https://vercel.com/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Database Schema](./database.sql)
- [Full Architecture](./FULL_STACK_ARCHITECTURE.md)

---

## ⚡ Common Tasks

### Add New Page
```bash
# 1. Create page
mkdir -p app/mypage
touch app/mypage/page.tsx

# 2. Add to navigation
# Edit app/layout.tsx
```

### Add New API Endpoint
```bash
# 1. Create route
mkdir -p api/myfeature
touch api/myfeature/route.ts

# 2. Implement handler
export async function GET/POST(request) { ... }
```

### Query Database
```typescript
// Frontend or Backend
const { data, error } = await supabase
  .from('table_name')
  .select('*')
  .eq('id', value)
```

### Insert Data
```typescript
await supabase
  .from('table_name')
  .insert({ field1: value1, field2: value2 })
```

### Watch Realtime
```typescript
supabase
  .from('table_name')
  .on('*', (payload) => {
    console.log('Change detected:', payload)
  })
  .subscribe()
```

---

## 🐛 Troubleshooting

| Error | Solution |
|-------|----------|
| "SUPABASE_URL not found" | Add to `.env.local` |
| "Unauthorized" | Check JWT token |
| "RLS policy violation" | Add RLS policy to table |
| "Function timeout" | Break into smaller functions |

---

## 📞 Support

- **Docs:** See INDEX.md for all documentation
- **Vercel Issues:** [Vercel Status](https://www.vercel-status.com/)
- **Supabase Issues:** [Supabase Status](https://status.supabase.com/)
- **Questions:** See FULL_STACK_ARCHITECTURE.md

---

## ✅ MVP Checklist

- [ ] Create Next.js project
- [ ] Setup Supabase database
- [ ] Deploy schema (database.sql)
- [ ] Create first API endpoint
- [ ] Create first page
- [ ] Test authentication
- [ ] Deploy to Vercel
- [ ] Setup custom domain
- [ ] Launch! 🎉

---

**Version:** 1.2  
**Last Updated:** 24 June 2026  
**Stack:** Next.js + Vercel + Supabase

---

**Questions?** Read the full docs starting with [FULL_STACK_ARCHITECTURE.md](./FULL_STACK_ARCHITECTURE.md)

