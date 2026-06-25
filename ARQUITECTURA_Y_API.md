# 📱 Real Estate Swipe App - Documentación Técnica Completa

## MVP (Minimum Viable Product)

---

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Modelo de Datos](#modelo-de-datos)
4. [Endpoints de la API](#endpoints-de-la-api)
5. [Flujos de Negocio](#flujos-de-negocio)
6. [Seguridad y Privacidad](#seguridad-y-privacidad)
7. [Guía de Implementación](#guía-de-implementación)

---

## Visión General

### Descripción del Producto

**Real Estate Swipe** es una plataforma móvil similar a Tinder, diseñada específicamente para el mercado inmobiliario. Permite:

- **Inquilinos/Compradores**: Deslizar (swipear) tarjetas de propiedades para indicar interés ("Like" o "Dislike")
- **Propietarios/Arrendadores**: Evaluar solicitudes de interés de inquilinos y realizar matches
- **Comunicación Directa**: Chat en tiempo real post-match entre inquilinos y propietarios

### Propuesta de Valor

✅ **Para Inquilinos:**
- Búsqueda visual intuitiva de propiedades
- Privacidad de datos: documentos sensibles ocultos hasta match definitivo
- Comunicación directa con propietarios

✅ **Para Propietarios:**
- Gestión eficiente de solicitudes de interés
- Evaluación de perfiles de inquilinos
- Auto-match automático (opcional)
- Contacto verificado con inquilinos

---

## Arquitectura del Sistema

### Stack Tecnológico Recomendado

```
┌────────────────────────────────────────────────────────────────┐
│                   ARQUITECTURA GENERAL                         │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  FRONTEND MÓVIL (iOS/Android)                                  │
│  ├─ React Native / Flutter                                     │
│  ├─ Redux / Zustand (State Management)                         │
│  ├─ React Query / Tanstack Query (Data Fetching)               │
│  └─ Geolocation API (Ubicación)                                │
│                                                                │
│  ↓↑ (REST API + WebSocket)                                     │
│                                                                │
│  BACKEND (Node.js + Express/NestJS)                            │
│  ├─ TypeScript                                                 │
│  ├─ Authentication: JWT + Refresh Tokens                       │
│  ├─ Real-time: Socket.io (Chat)                                │
│  ├─ File Upload: Multer + AWS S3                               │
│  ├─ Encryption: bcrypt (passwords), TweetNaCl (docs)           │
│  └─ Queue: Bull/RabbitMQ (notificaciones)                      │
│                                                                │
│  ↓↑ (SQL Queries)                                              │
│                                                                │
│  DATABASE (PostgreSQL 13+)                                     │
│  ├─ JSONB para amenities/extra_areas                           │
│  ├─ Full-text search (tsvector)                                │
│  ├─ Triggers para automatización                               │
│  └─ Row-Level Security (RLS)                                   │
│                                                                │
│  ↓↑ (HTTP)                                                     │
│                                                                │
│  CACHE & SESSION (Redis)                                       │
│  ├─ Session tokens                                             │
│  ├─ Swipe stack cache                                          │
│  ├─ Rate limiting                                              │
│  └─ Real-time notifications                                    │
│                                                                │
│  ↓↑ (API)                                                      │
│                                                                │
│  EXTERNAL SERVICES                                             │
│  ├─ AWS S3 (Document Storage - Encrypted)                      │
│  ├─ SendGrid/Twilio (Email/SMS)                                │
│  ├─ Firebase Cloud Messaging (Push Notifications)              │
│  └─ Stripe/PayU (Payments - Future)                            │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### ¿Por qué esta arquitectura?

| Componente | Razón |
|-----------|-------|
| **React Native/Flutter** | Código compartido iOS/Android, time-to-market rápido |
| **Node.js + Express** | Excelente para APIs en tiempo real, comunidad grande, fácil escalabilidad |
| **TypeScript** | Type safety, mejor DX, previene bugs en producción |
| **PostgreSQL** | Relaciones complejas (usuarios→propiedades→swipes→matches), JSONB flexible |
| **Socket.io** | Chat en tiempo real, fallback a long-polling, fácil de usar |
| **Redis** | Caché rápido (stacks de swipe), sesiones distribuidas |
| **AWS S3** | Almacenamiento escalable, encriptación en reposo, CDN |

---

## Modelo de Datos

### Diagrama Entidad-Relación (Conceptual)

```
┌─────────────────────────┐
│        USERS            │
├─────────────────────────┤
│ PK: user_id (UUID)      │
│ • email (UNIQUE)        │
│ • role (tenant/owner)   │
│ • full_name             │
│ • profile_completed     │
│ • auto_match_enabled    │
└──────────┬──────────────┘
           │
    ┌──────┴─────────────┐
    │                    │
    ▼                    ▼
┌──────────────┐  ┌──────────────┐
│ TENANT       │  │ OWNER        │
│ PROFILES     │  │ PROFILES     │
├──────────────┤  ├──────────────┤
│ PK: FK user_id   │ PK: FK user_id
│ • description    │ • business_name
│ • income_range   │ • verification_status
└──────┬───────┘  └────────┬─────┘
       │                   │
       │                   ▼
       │          ┌──────────────────┐
       │          │ PROPERTIES       │
       │          ├──────────────────┤
       │          │ PK: property_id  │
       │          │ FK: owner_id ✓   │
       │          │ • title          │
       │          │ • price_monthly  │
       │          │ • bedrooms       │
       │          │ • city           │
       │          └────────┬─────────┘
       │                   │
       │                   ├─────────────────┬─────────────────┐
       │                   │                 │                 │
       │                   ▼                 ▼                 ▼
       │        ┌─────────────────┐ ┌────────────────┐ ┌─────────────────┐
       │        │ SWIPES          │ │ PROPERTIES     │ │ DOCUMENTATION   │
       │        │ (Like/Dislike)  │ │ _MEDIA         │ │ _HUB            │
       │        ├─────────────────┤ ├────────────────┤ ├─────────────────┤
       │        │ PK: swipe_id    │ │ PK: media_id   │ │ PK: doc_id      │
       │        │ FK: tenant_id ✓ │ │ FK: property   │ │ FK: user_id ✓   │
       │        │ FK: property ✓  │ │ • media_url    │ │ • id_document   │
       │        │ FK: owner_id ✓  │ │ • display_order│ │ • income_proof  │
       │        │ • action (like) │ └────────────────┘ │ • visibility    │
       │        │ • request_status│                    │ • is_encrypted  │
       │        └────────┬────────┘                    └────────┬────────┘
       │                 │                                     │
       │                 └──────────────────┬──────────────────┘
       │                                    │
       │                                    ▼
       │                          ┌──────────────────┐
       │                          │ MATCHES          │
       │                          │ (Match Definitivo)
       │                          ├──────────────────┤
       │                          │ PK: match_id     │
       │                          │ FK: tenant_id ✓  │
       │                          │ FK: property ✓   │
       │                          │ FK: owner_id ✓   │
       │                          │ • status         │
       │                          │ • tenant_docs_   │
       │                          │   revealed ✓✓    │
       │                          │ • owner_docs_    │
       │                          │   revealed ✓✓    │
       │                          └────────┬─────────┘
       │                                   │
       │                                   ▼
       │                        ┌──────────────────────┐
       │                        │ CHAT_CONVERSATIONS  │
       │                        ├──────────────────────┤
       │                        │ PK: conversation_id  │
       │                        │ FK: match_id (UNIQUE)│
       │                        │ FK: tenant_id ✓      │
       │                        │ FK: owner_id ✓       │
       │                        └────────┬─────────────┘
       │                                 │
       │                                 ▼
       │                      ┌──────────────────────┐
       │                      │ CHAT_MESSAGES        │
       │                      ├──────────────────────┤
       │                      │ PK: message_id       │
       │                      │ FK: conversation_id  │
       │                      │ FK: sender_id ✓      │
       │                      │ FK: recipient_id ✓   │
       │                      │ • message_body       │
       │                      │ • is_read            │
       │                      └──────────────────────┘
       │
       ▼
┌──────────────────────┐
│ TENANT_GUARANTORS    │
├──────────────────────┤
│ PK: guarantor_id     │
│ FK: tenant_id ✓      │
│ • full_name          │
│ • relationship       │
│ • phone/email        │
└──────────────────────┘
```

### Tablas Principales (Descripción Detallada)

Ver archivo `database.sql` para el schema SQL completo.

---

## Endpoints de la API

### Base URL
```
https://api.realestateswipe.com/v1
```

### Autenticación

Todos los endpoints protegidos requieren:
```
Authorization: Bearer <JWT_ACCESS_TOKEN>
Content-Type: application/json
```

### 🔐 AUTENTICACIÓN

#### POST `/auth/register`
Crear nueva cuenta

**Request:**
```json
{
  "email": "juan@example.com",
  "phone": "+57xxxxxxxxx",
  "password": "SecurePass123!",
  "full_name": "Juan Pérez",
  "role": "tenant",
  "bio": "Busco apartamento en zona residencial"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "juan@example.com",
    "role": "tenant",
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

---

#### POST `/auth/login`
Iniciar sesión

**Request:**
```json
{
  "email": "juan@example.com",
  "password": "SecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

---

#### POST `/auth/refresh-token`
Refrescar access token

**Request:**
```json
{
  "refresh_token": "eyJhbGc..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

---

### 👤 PERFILES DE USUARIO

#### POST `/tenants/profile`
Crear/Completar perfil de Inquilino (**MANDATORY**)

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "description": "Profesional de 28 años, busco apartamento en Zona Rosa con gimnasio",
  "income_range_id": 3,
  "occupation": "Ingeniero de Software",
  "years_experience": 5
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "tenant_id": "550e8400-e29b-41d4-a716-446655440000",
    "profile_completed": true,
    "description": "Profesional de 28 años...",
    "income_range": {
      "range_id": 3,
      "label": "$1000-$2000"
    }
  }
}
```

---

#### POST `/tenants/{tenant_id}/guarantor`
Agregar avalista

**Request:**
```json
{
  "full_name": "María García",
  "relationship": "Madre",
  "phone": "+57xxxxxxxxx",
  "email": "maria@example.com"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "guarantor_id": "550e8400-e29b-41d4-a716-446655440000",
    "full_name": "María García",
    "relationship": "Madre"
  }
}
```

---

#### POST `/owners/profile`
Crear/Completar perfil de Propietario (**MANDATORY**)

**Request:**
```json
{
  "business_name": "García Inmuebles SAS",
  "company_reg_number": "NIT-123456789",
  "bank_name": "Banco de Bogotá",
  "account_holder_name": "García Inmuebles SAS"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "owner_id": "550e8400-e29b-41d4-a716-446655440000",
    "business_name": "García Inmuebles SAS",
    "verification_status": "pending",
    "profile_completed": true,
    "auto_match_enabled": false
  }
}
```

---

#### PATCH `/owners/{owner_id}/settings`
Actualizar configuración (Switch Auto-Match)

**Request:**
```json
{
  "auto_match_enabled": true,
  "notifications_enabled": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "owner_id": "550e8400-e29b-41d4-a716-446655440000",
    "auto_match_enabled": true
  }
}
```

---

### 🏘️ PROPIEDADES

#### POST `/properties`
Crear anuncio de propiedad (**OWNER ONLY, TODOS CAMPOS MANDATORY**)

**Request:**
```json
{
  "title": "Apartamento 3 hab, Zona Rosa, Bogotá",
  "description": "Hermoso apartamento con vista al parque, recién renovado",
  "price_monthly": 1500,
  "price_sale": null,
  
  "area_sqm": 95.5,
  "bedrooms": 3,
  "bathrooms": 2,
  "floors": 12,
  "parking_spaces": 1,
  "floor_number": 8,
  
  "has_elevator": true,
  "pet_friendly": false,
  "monthly_aliquot": 250000,
  
  "amenities": ["piscina", "gimnasio", "parque", "seguridad 24/7"],
  "extra_areas": ["bodega", "balcón grande"],
  
  "address": "Calle 85 # 15-60",
  "city": "Bogotá",
  "state_province": "Cundinamarca",
  "postal_code": "110220",
  "latitude": 4.7244,
  "longitude": -74.0699,
  "country_code": "COL",
  
  "cover_image_url": "https://s3.amazonaws.com/..."
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "property_id": "550e8400-e29b-41d4-a716-446655440000",
    "owner_id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Apartamento 3 hab, Zona Rosa, Bogotá",
    "price_monthly": 1500,
    "bedrooms": 3,
    "city": "Bogotá",
    "listing_status": "active",
    "view_count": 0,
    "created_at": "2026-06-24T10:30:00Z"
  }
}
```

---

#### POST `/properties/{property_id}/media`
Subir imágenes/documentos de propiedad

**Content-Type:** `multipart/form-data`

**Form Data:**
- `files`: [file1.jpg, file2.jpg, documento.pdf]
- `media_types`: ["image", "image", "document"]

**Response (201):**
```json
{
  "success": true,
  "data": {
    "media_files": [
      {
        "media_id": "550e8400-e29b-41d4-a716-446655440000",
        "property_id": "550e8400-e29b-41d4-a716-446655440001",
        "media_type": "image",
        "media_url": "https://s3.amazonaws.com/...",
        "display_order": 1
      }
    ]
  }
}
```

---

#### GET `/properties/{property_id}`
Obtener detalles de propiedad (**PUBLIC**)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "property_id": "550e8400-e29b-41d4-a716-446655440000",
    "owner_id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Apartamento 3 hab, Zona Rosa",
    "description": "Hermoso apartamento...",
    "price_monthly": 1500,
    "area_sqm": 95.5,
    "bedrooms": 3,
    "bathrooms": 2,
    "city": "Bogotá",
    "amenities": ["piscina", "gimnasio"],
    "media": [
      {
        "media_id": "550e8400-e29b-41d4-a716-446655440000",
        "media_type": "image",
        "media_url": "https://s3.amazonaws.com/..."
      }
    ],
    "view_count": 42,
    "swipe_count": 12
  }
}
```

---

#### GET `/properties`
Listar propiedades con filtros

**Query Parameters:**
```
GET /properties?city=Bogotá&min_price=1000&max_price=3000&bedrooms=3&pet_friendly=true&limit=20&offset=0&sort_by=recent
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total": 1234,
    "limit": 20,
    "offset": 0,
    "properties": [
      {
        "property_id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Apartamento 3 hab...",
        "price_monthly": 1500,
        "bedrooms": 3,
        "area_sqm": 95.5,
        "city": "Bogotá",
        "cover_image_url": "https://s3.amazonaws.com/..."
      }
    ]
  }
}
```

---

### 🔄 SWIPES

#### GET `/swipe/stack`
Obtener stack de propiedades para swipear (**TENANT ONLY**)

**⚠️ LÓGICA CRÍTICA:**
- Retorna propiedades que el inquilino NO HA SWIPED AÚN
- Ordena por relevancia (ciudad, precio, amenities)
- Caché en Redis para performance

**Query Parameters:**
```
GET /swipe/stack?city=Bogotá&limit=10&offset=0
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "available_count": 456,
    "stack": [
      {
        "property_id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Apartamento 3 hab, Zona Rosa",
        "price_monthly": 1500,
        "bedrooms": 3,
        "bathrooms": 2,
        "area_sqm": 95.5,
        "has_elevator": true,
        "amenities": ["piscina", "gimnasio"],
        "media": [
          {
            "media_id": "550e8400-e29b-41d4-a716-446655440000",
            "media_type": "image",
            "media_url": "https://s3.amazonaws.com/..."
          }
        ]
      }
    ]
  }
}
```

---

#### POST `/swipe`
Registrar un swipe (**TENANT ONLY**)

**⚠️ LÓGICA DE NEGOCIO:**
- `like`: Crea `swipes` con `request_status: "pending"` + notificación al owner
- `dislike`: Registra swipe, owner NO ve nada
- `later`: Guardar para después, no consumir del stack

**Request:**
```json
{
  "property_id": "550e8400-e29b-41d4-a716-446655440000",
  "action": "like"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "swipe_id": "550e8400-e29b-41d4-a716-446655440000",
    "tenant_id": "550e8400-e29b-41d4-a716-446655440001",
    "property_id": "550e8400-e29b-41d4-a716-446655440002",
    "action": "like",
    "request_status": "pending",
    "message": "¡Te ha gustado este inmueble! El propietario verá tu solicitud.",
    "request_created_at": "2026-06-24T10:30:00Z"
  }
}
```

---

### ⭐ MATCHES Y SOLICITUDES

#### GET `/owner/interest-requests`
Obtener solicitudes de interés para el propietario (**OWNER ONLY**)

**⚠️ PRIVACIDAD CRÍTICA:**
- Muestra perfil del inquilino SIN documentación confidencial
- ✅ Visible: Nombre, descripción, rango de ingresos, info del avalista
- ❌ Oculto: Cédula, comprobantes de ingresos, documentos del avalista

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_requests": 12,
    "requests": [
      {
        "swipe_id": "550e8400-e29b-41d4-a716-446655440000",
        "property_id": "550e8400-e29b-41d4-a716-446655440001",
        "tenant_id": "550e8400-e29b-41d4-a716-446655440002",
        "request_status": "pending",
        "request_created_at": "2026-06-24T10:30:00Z",
        
        "tenant_profile": {
          "user_id": "550e8400-e29b-41d4-a716-446655440002",
          "full_name": "Juan Pérez",
          "bio": "Profesional buscando apto en Zona Rosa",
          "description": "Ingeniero de Software con 5 años de experiencia",
          "income_range": {
            "range_id": 3,
            "label": "$1000-$2000"
          },
          "occupation": "Ingeniero de Software",
          "years_experience": 5,
          
          "guarantor": {
            "guarantor_id": "550e8400-e29b-41d4-a716-446655440003",
            "full_name": "María García",
            "relationship": "Madre",
            "phone": "+57xxxxxxxxx",
            "email": "maria@example.com"
          }
        },
        
        "sensitive_documents": null
      }
    ]
  }
}
```

---

#### POST `/owner/interest-requests/{swipe_id}/approve`
Propietario aprueba solicitud → **GENERA MATCH DEFINITIVO**

**⚠️ LÓGICA CRÍTICA (AUTO-TRIGGERED):**
1. Crea fila en tabla `matches` con `status: "matched"`
2. Desbloquea automáticamente TODOS los documentos (tenant_docs_revealed = true)
3. Abre chat automáticamente
4. Envía notificación a ambos

**Request:**
```json
{
  "message": "Me interesa concertar una cita este fin de semana"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "match_id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "matched",
    "tenant_id": "550e8400-e29b-41d4-a716-446655440002",
    "property_id": "550e8400-e29b-41d4-a716-446655440001",
    
    "tenant_docs_revealed": true,
    "owner_docs_revealed": true,
    "guarantor_info_revealed": true,
    
    "tenant_full_profile": {
      "user_id": "550e8400-e29b-41d4-a716-446655440002",
      "full_name": "Juan Pérez",
      "description": "...",
      
      "id_document": {
        "doc_id": "550e8400-e29b-41d4-a716-446655440000",
        "id_document_number": "1234567890",
        "id_document_type": "cedula",
        "id_document_url": "https://s3.amazonaws.com/..."
      },
      
      "income_proof": {
        "doc_id": "550e8400-e29b-41d4-a716-446655440001",
        "income_proof_url": "https://s3.amazonaws.com/...",
        "bank_statement_url": "https://s3.amazonaws.com/...",
        "employment_letter_url": "https://s3.amazonaws.com/..."
      },
      
      "guarantor": {
        "guarantor_id": "550e8400-e29b-41d4-a716-446655440003",
        "full_name": "María García",
        "guarantor_documents": {
          "doc_id": "550e8400-e29b-41d4-a716-446655440002",
          "document_url": "https://s3.amazonaws.com/..."
        }
      }
    },
    
    "owner_info": {
      "full_name": "Carlos García",
      "business_name": "García Inmuebles SAS",
      "property_title_deed_url": "https://s3.amazonaws.com/..."
    },
    
    "chat_conversation": {
      "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
      "match_id": "550e8400-e29b-41d4-a716-446655440000",
      "is_active": true,
      "created_at": "2026-06-24T10:30:00Z"
    },
    
    "match_confirmed_date": "2026-06-24T10:30:00Z"
  }
}
```

---

#### POST `/owner/interest-requests/{swipe_id}/decline`
Propietario rechaza solicitud

**Request:**
```json
{
  "reason": "optional-reason"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "swipe_id": "550e8400-e29b-41d4-a716-446655440000",
    "request_status": "owner_declined",
    "declined_at": "2026-06-24T10:30:00Z"
  }
}
```

---

### 💬 CHAT (Post-Match)

#### GET `/chat/conversations`
Obtener todas las conversaciones del usuario

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_conversations": 5,
    "conversations": [
      {
        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
        "match_id": "550e8400-e29b-41d4-a716-446655440001",
        "property_id": "550e8400-e29b-41d4-a716-446655440002",
        
        "other_user": {
          "user_id": "550e8400-e29b-41d4-a716-446655440003",
          "full_name": "Carlos García"
        },
        
        "property_info": {
          "property_id": "550e8400-e29b-41d4-a716-446655440002",
          "title": "Apartamento 3 hab, Zona Rosa",
          "price_monthly": 1500
        },
        
        "last_message_at": "2026-06-24T10:30:00Z",
        "unread_count": 2
      }
    ]
  }
}
```

---

#### GET `/chat/conversations/{conversation_id}/messages`
Obtener mensajes de una conversación

**Query Parameters:**
```
GET /chat/conversations/550e8400-e29b-41d4-a716-446655440000/messages?limit=20&offset=0
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
    "total_messages": 45,
    "messages": [
      {
        "message_id": "550e8400-e29b-41d4-a716-446655440000",
        "conversation_id": "550e8400-e29b-41d4-a716-446655440001",
        "sender_id": "550e8400-e29b-41d4-a716-446655440002",
        "sender_name": "Juan Pérez",
        "message_body": "¡Hola! Me interesa mucho el apartamento",
        "message_type": "text",
        "is_read": true,
        "created_at": "2026-06-24T10:30:00Z"
      }
    ]
  }
}
```

---

#### POST `/chat/conversations/{conversation_id}/messages`
Enviar mensaje (Synced con WebSocket)

**Request:**
```json
{
  "message_body": "¿Podemos agendar una visita para mañana?",
  "message_type": "text"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "message_id": "550e8400-e29b-41d4-a716-446655440000",
    "conversation_id": "550e8400-e29b-41d4-a716-446655440001",
    "message_body": "¿Podemos agendar una visita para mañana?",
    "created_at": "2026-06-24T10:30:00Z"
  }
}
```

---

## Flujos de Negocio

### Flujo 1: Registro y Completado de Perfil

```
┌─────────────────────────────────────────────┐
│ 1. Usuario hace POST /auth/register         │
└────────┬────────────────────────────────────┘
         │ Backend crea fila en 'users'
         │ profile_completed = false
         ▼
┌─────────────────────────────────────────────┐
│ 2. Según rol, requiere:                     │
│    - TENANT: POST /tenants/profile          │
│    - OWNER: POST /owners/profile            │
└────────┬────────────────────────────────────┘
         │ Ambos son MANDATORY
         ▼
┌─────────────────────────────────────────────┐
│ 3. Backend valida completitud de datos      │
│    profile_completed = true                 │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│ 4. Usuario puede acceder a:                 │
│    - TENANT: GET /swipe/stack               │
│    - OWNER: POST /properties                │
└─────────────────────────────────────────────┘
```

---

### Flujo 2: Swipe → Match Definitivo → Chat

```
FASE 1: SWIPE DEL INQUILINO
┌──────────────────────────────────────────┐
│ 1. GET /swipe/stack                      │
│    Backend retorna propiedades no-swiped │
│    Cache en Redis (TTL: 5 min)           │
└────────┬─────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│ 2. Inquilino observa tarjeta de propiedad│
│    Información visible:                  │
│    - Título, descripción, fotos          │
│    - Precio, m², habitaciones, ubicación │
│    - Amenities, información del dueño    │
│    ❌ NO: Documentos legales (aún)       │
└────────┬─────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│ 3. Inquilino hace swipe:                 │
│    POST /swipe {like | dislike}          │
└────────┬─────────────────────────────────┘
         │
         ├─ LIKE:
         │  ├─ Crea fila en 'swipes'
         │  ├─ request_status = 'pending'
         │  ├─ Envía notificación al owner
         │  └─ "Nueva solicitud de interés"
         │
         └─ DISLIKE:
            ├─ Crea fila en 'swipes'
            ├─ request_status = 'pending'
            └─ Owner NO ve nada

FASE 2: EVALUACIÓN DEL PROPIETARIO
┌──────────────────────────────────────────┐
│ 1. GET /owner/interest-requests           │
│    Owner obtiene lista de solicitudes     │
│    información del inquilino VISIBLE:     │
│    ✅ Nombre, descripción, ingresos      │
│    ✅ Info del avalista (sin documentos) │
│    ❌ Cédula                              │
│    ❌ Comprobantes de ingresos            │
└────────┬─────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│ 2. Owner decide:                         │
│    [LIKE] [DISLIKE] [LATER]              │
└────────┬─────────────────────────────────┘
         │
         ├─ LIKE: POST /owner/interest-requests/{id}/approve
         │  │
         │  └─→ MATCH DEFINITIVO ✅
         │
         └─ DISLIKE: POST /owner/interest-requests/{id}/decline

FASE 3: MATCH DEFINITIVO ✅
┌────────────────────────────────────────────────┐
│ INSTANTÁNEAMENTE (Backend Trigger):            │
│                                                │
│ 1. Crea fila en 'matches'                      │
│    status = 'matched'                          │
│                                                │
│ 2. Desbloquea documentación (AMBOS LADOS):     │
│    ✅ tenant_docs_revealed = true              │
│    ✅ owner_docs_revealed = true               │
│    ✅ guarantor_info_revealed = true           │
│                                                │
│ 3. En DocumentationHub:                        │
│    visibility_status = 'match_visible'         │
│                                                │
│ 4. Crea chat_conversation                      │
│    is_active = true                            │
│                                                │
│ 5. Ambos usuarios reciben notificación:        │
│    Inquilino: "¡MATCH! Conoce a {owner}"       │
│    Owner: "¡MATCH! Nuevo inquilino interesado" │
│                                                │
│ 6. API retorna TODA la información:            │
│    - Documentos de inquilino (AHORA VISIBLES)  │
│    - Documentos de propietario                 │
│    - Detalles del chat                         │
└────────────────────────────────────────────────┘

FASE 4: COMUNICACIÓN EN CHAT
┌──────────────────────────────────────────┐
│ 1. POST /chat/messages                   │
│    Ambos pueden comunicarse               │
│                                          │
│ 2. WebSocket en tiempo real               │
│    Socket.io transmite mensajes           │
│                                          │
│ 3. Pueden:                                │
│    - Agendar visitas                      │
│    - Compartir documentos                 │
│    - Acordar términos                     │
│    - Coordinarse                          │
└──────────────────────────────────────────┘
```

---

### Flujo 3: Lógica de Privacidad de Documentos

```
ESTADO: ANTES DEL MATCH
═══════════════════════════════════════════

Inquilino Profile (VISIBLE al Propietario):
✅ Nombre completo
✅ Descripción/Bio
✅ Rango de ingresos (ej: $1000-$2000)
✅ Ocupación
✅ Información básica del avalista (nombre, relación)
✅ Teléfono del avalista
❌ OCULTO: Cédula del inquilino
❌ OCULTO: Comprobantes de ingresos
❌ OCULTO: Documentos del avalista
❌ OCULTO: Extractos bancarios


Propietario Profile (VISIBLE al Inquilino):
✅ Nombre del propietario
✅ Nombre del negocio
✅ Datos de contacto
✅ Descripción de la propiedad
❌ OCULTO: Documentos legales de la propiedad
❌ OCULTO: Información bancaria
❌ OCULTO: Detalles de contratos


DATABASE STATE:
documentation_hub.visibility_status = 'private'


═══════════════════════════════════════════

ESTADO: DESPUÉS DEL MATCH
═══════════════════════════════════════════

✅ TODO SE REVELA AUTOMÁTICAMENTE

Inquilino Profile (COMPLETO):
✅ Cédula/Pasaporte (encriptado)
✅ Comprobantes de ingresos (encriptado)
✅ Extractos bancarios (encriptado)
✅ Carta de empleo (encriptado)
✅ Todos los documentos del avalista


Propietario Profile (COMPLETO):
✅ Escritura de la propiedad (encriptado)
✅ Certificado de impuestos (encriptado)
✅ Autorización legal (encriptado)
✅ Información bancaria (encriptado)


DATABASE STATE:
matches.tenant_docs_revealed = true
matches.owner_docs_revealed = true
matches.guarantor_info_revealed = true

documentation_hub.visibility_status = 'match_visible'
═══════════════════════════════════════════
```

---

### Flujo 4: Auto-Match (Switch del Propietario)

```
CONFIGURACIÓN DEL PROPIETARIO
┌────────────────────────────────────────┐
│ PATCH /owners/{id}/settings            │
│                                        │
│ {                                      │
│   "auto_match_enabled": true/false    │
│ }                                      │
│                                        │
│ Almacenado en: users.auto_match_enabled
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ CUANDO INQUILINO DA LIKE               │
│ POST /swipe {property_id, "like"}      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│ Backend verifica:                      │
│ auto_match_enabled = true ?            │
└────────┬───────────────────────────────┘
         │
    ┌────┴─────────────┐
    │                  │
   YES                NO
    │                  │
    ▼                  ▼
┌────────────┐   ┌──────────────────────┐
│ AUTO-MATCH │   │ Propietario revisa   │
│ INMEDIATO  │   │ manualmente          │
│            │   │ GET /owner/interest- │
│ 1. Crea    │   │ requests             │
│    match   │   └──────────────────────┘
│ 2. Abre    │
│    chat    │
│ 3. Revela  │
│    docs    │
│ 4. Notif   │
│    ambos   │
└────────────┘
```

---

## Seguridad y Privacidad

### Autenticación

- **JWT con Access & Refresh Tokens**
  - Access Token: 1 hora de validez
  - Refresh Token: 30 días de validez
  - Almacenar en Redis para revocación instantánea

- **Contraseñas**
  - Salted bcrypt (10+ rounds)
  - Nunca almacenar en texto plano

### Encriptación de Documentos

- **End-to-End Encryption:**
  - Frontend: Encriptar documento antes de enviar
  - Backend: Guardar encriptado en S3
  - Decryption key: Generada en frontend, sincronizada con backend

- **Algoritmo:** TweetNaCl.js (curva25519-poly1305)

### Control de Acceso

```
documento_sensible.visibility:

- BEFORE MATCH: 'private'
  ├─ Solo propietario puede acceder
  └─ Error 403 si otro intenta descargar

- AFTER MATCH: 'match_visible'
  ├─ Inquilino puede descargar sus propios docs
  ├─ Propietario puede descargar docs del inquilino
  ├─ Inquilino puede descargar docs del propietario
  └─ Garantor puede descargar sus propios docs
```

### Rate Limiting

```
- POST /auth/login: 5 intentos por IP en 15 minutos
- POST /swipe: 100 swipes por hora por usuario
- POST /chat/messages: 50 mensajes por 5 minutos por usuario
```

### GDPR & Compliance

- **Derecho al Olvido:**
  - Soft delete de datos sensibles
  - Hard delete después de 90 días

- **Auditoría:**
  - Log de accesos a documentos sensibles
  - Timestamp de revelación de información

---

## Guía de Implementación

### Fase 1: Setup Inicial (Semana 1-2)

1. **Backend Setup**
   ```bash
   npm init -y
   npm install express dotenv cors helmet jwt bcryptjs
   npm install pg @types/pg redis socket.io
   npm install multer aws-sdk-v3 sharp
   npm install --save-dev typescript @types/express @types/node
   ```

2. **Database**
   ```bash
   createdb realestateswipe
   psql realestateswipe < database.sql
   ```

3. **Environment Variables** (`.env`)
   ```
   DATABASE_URL=postgresql://user:pass@localhost:5432/realestateswipe
   JWT_SECRET=your-secret-key-change-in-production
   REFRESH_TOKEN_SECRET=your-refresh-secret
   REDIS_URL=redis://localhost:6379
   AWS_ACCESS_KEY_ID=xxx
   AWS_SECRET_ACCESS_KEY=xxx
   AWS_S3_BUCKET=realestateswipe-docs
   NODE_ENV=development
   ```

### Fase 2: Endpoints Críticos (Semana 3-4)

Implementar en orden de dependencia:

1. **Autenticación**
   - ✅ POST /auth/register
   - ✅ POST /auth/login
   - ✅ POST /auth/refresh-token

2. **Perfiles**
   - ✅ POST /tenants/profile
   - ✅ POST /owners/profile
   - ✅ PATCH /owners/settings

3. **Propiedades**
   - ✅ POST /properties
   - ✅ GET /properties
   - ✅ GET /properties/{id}

4. **Swipes**
   - ✅ GET /swipe/stack
   - ✅ POST /swipe

5. **Matches**
   - ✅ GET /owner/interest-requests
   - ✅ POST /owner/interest-requests/{id}/approve
   - ✅ POST /owner/interest-requests/{id}/decline

6. **Chat**
   - ✅ GET /chat/conversations
   - ✅ GET /chat/conversations/{id}/messages
   - ✅ POST /chat/conversations/{id}/messages

### Fase 3: Frontend Móvil (Semana 5-6)

1. **Setup React Native**
   ```bash
   npx react-native init RealEstateSwipe
   npm install @react-navigation/native @react-native-async-storage/async-storage
   npm install axios react-query zustand
   npm install @react-native-camera-roll/camera-roll react-native-image-picker
   ```

2. **Screens Principales**
   - Auth Stack (Login, Register)
   - Tenant Stack (Swipe, Matches, Chat)
   - Owner Stack (Properties, Requests, Chat)

3. **State Management**
   - Zustand store para auth, user, properties
   - React Query para server state

---

## Resumen Ejecutivo

### MVP Alcance

✅ **Autenticación segura** con JWT
✅ **Perfiles de usuario** (Tenant + Owner)
✅ **Gestión de propiedades** (CRUD)
✅ **Lógica de swipe** (Like/Dislike/Later)
✅ **Sistema de solicitudes** (Interest Requests)
✅ **Matches definitivos** con auto-reveal de documentos
✅ **Chat en tiempo real** (Post-match)
✅ **Privacidad de datos** (Encriptación de documentos)
✅ **Auto-match** (Switch configurable)

### Características Futuras (Post-MVP)

🚀 Pagos y depósitos
🚀 Verificación de propietarios/inquilinos
🚀 Sistema de calificaciones y reseñas
🚀 Recomendaciones AI/ML
🚀 Búsqueda geográfica avanzada
🚀 Contratos electrónicos (e-signature)
🚀 Sistema de seguros
🚀 Aplicación web (Next.js)

---

**Última actualización:** 24 de Junio de 2026
**Stack:** Node.js + PostgreSQL + React Native + Socket.io
**Versión API:** v1.0

