# 🚀 Quick Start Supabase - Real Estate Swipe

## 5 minutos para tener tu MVP listo

---

## 1️⃣ Crear Proyecto Supabase (2 min)

```bash
# 1. Ir a https://supabase.com
# 2. Click en "Start your project"
# 3. Sign up con GitHub o email
# 4. Create a new project:
#    Project name: realestateswipe
#    Password: strong-password-here
#    Region: Select your region (e.g., South America - São Paulo)
# 5. Wait for deployment...
# ✅ Proyecto creado!
```

---

## 2️⃣ Setup Database (1 min)

```bash
# En Supabase Console:
# 1. Go to SQL Editor (left menu)
# 2. New Query
# 3. Copy-paste TODO el contenido de database.sql
# 4. Click "Run"
# ✅ Todas las tablas creadas!

# Verifica en Tables section (left menu)
```

---

## 3️⃣ Obtener Credenciales (1 min)

```bash
# En Supabase Console:
# Settings → API

# Copia y guarda en .env:
SUPABASE_URL=https://xxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...  # ⚠️ Guardar SEGURO

# ANON_KEY es para frontend
# SERVICE_KEY es solo para backend (nunca exponer)
```

---

## 4️⃣ Setup Frontend (1 min)

```bash
cd mobile

npm install @supabase/supabase-js @react-native-async-storage/async-storage

# Create: src/lib/supabase.ts
```

**Archivo: src/lib/supabase.ts**

```typescript
import { createClient } from '@supabase/supabase-js'
import AsyncStorage from '@react-native-async-storage/async-storage'

export const supabase = createClient(
  process.env.REACT_APP_SUPABASE_URL,
  process.env.REACT_APP_SUPABASE_ANON_KEY,
  {
    auth: {
      storage: AsyncStorage,
      autoRefreshToken: true,
      persistSession: true,
    },
  }
)
```

---

## 5️⃣ Primer Feature: Login (Bonus)

**Archivo: src/screens/auth/LoginScreen.tsx**

```typescript
import React, { useState } from 'react'
import { View, TextInput, Button, Alert } from 'react-native'
import { supabase } from '../../lib/supabase'

export default function LoginScreen() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = async () => {
    setLoading(true)
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      Alert.alert('Error', error.message)
    } else {
      Alert.alert('Success', 'Logged in!')
      // Navigate to home
    }
    setLoading(false)
  }

  return (
    <View style={{ padding: 20 }}>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      <Button
        title={loading ? 'Logging in...' : 'Login'}
        onPress={handleLogin}
        disabled={loading}
      />
    </View>
  )
}
```

---

## 📱 Ahora tienes:

✅ Base de datos PostgreSQL (12 tablas)  
✅ Autenticación nativa  
✅ Storage integrado  
✅ Realtime subscriptions  
✅ Edge Functions (serverless)  

---

## 🔐 RLS Security Policies

Ejecuta en SQL Editor para proteger datos:

```sql
-- Documentos privados hasta match
ALTER TABLE documentation_hub ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own documents"
  ON documentation_hub FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Matched users see revealed docs"
  ON documentation_hub FOR SELECT
  USING (
    visibility_status = 'match_visible' AND
    EXISTS(
      SELECT 1 FROM matches m
      WHERE ((m.tenant_id = auth.uid() AND m.tenant_docs_revealed = true)
        OR (m.owner_id = auth.uid() AND m.owner_docs_revealed = true))
      AND m.status = 'matched'
    )
  );

-- Chat entre matched users
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see their messages"
  ON chat_messages FOR SELECT
  USING (
    sender_id = auth.uid() OR recipient_id = auth.uid()
  );
```

---

## 🌍 Deploy a Producción

```bash
# Frontend (Vercel)
npm run build
vercel

# Supabase está en producción automáticamente ✓
```

---

## 💡 Ejemplos de Uso

### GET Properties

```typescript
const { data: properties } = await supabase
  .from('properties')
  .select('*')
  .eq('city', 'Bogotá')
  .eq('listing_status', 'active')
```

### POST Swipe

```typescript
await supabase.from('swipes').insert({
  tenant_id: user.id,
  property_id: propertyId,
  action: 'like',
})
```

### Realtime Chat

```typescript
supabase
  .from(`chat_messages:conversation_id=eq.${conversationId}`)
  .on('INSERT', (payload) => {
    addMessage(payload.new)
  })
  .subscribe()
```

### Upload Document

```typescript
const { data, error } = await supabase.storage
  .from('documents')
  .upload(`${userId}/cedula.pdf`, file)
```

---

## 🎯 Próximos Pasos

1. Deploy database schema ✅
2. Setup Supabase Auth ✅
3. Create login/signup screens
4. Build swipe stack component
5. Implement realtime chat
6. Setup RLS policies
7. Deploy to app stores

---

## 📚 Links Útiles

- [Supabase Docs](https://supabase.com/docs)
- [React Native Guide](https://supabase.com/docs/guides/getting-started/quickstarts/react-native)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [SQL Editor](https://supabase.com/docs/guides/database/sql-editor)

---

## 🆘 Help

| Problema | Solución |
|----------|----------|
| "Connection refused" | Verifica SUPABASE_URL |
| "Invalid API key" | Copia ANON_KEY nuevamente |
| "Auth error" | Verifica email/password |
| "RLS denies" | Revisa policies |

---

**¡Listo! Tu backend está 100% operacional.**

Sin DevOps. Sin servidores. Solo código.

🚀 Happy coding!

