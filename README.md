# 🏠 Real Estate Swipe App - MVP

Una plataforma web tipo Tinder para el mercado inmobiliario que conecta inquilinos/compradores con propietarios/arrendadores de forma segura y eficiente.

**Stack:** Next.js + Vercel + Supabase | **Cost:** $150/mes | **Timeline:** 4-6 weeks

---

## 📋 Tabla de Contenidos

- [Visión General](#visión-general)
- [Características Principales](#características-principales)
- [Stack Tecnológico](#stack-tecnológico)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Guías Rápidas](#guías-rápidas)
- [Documentación](#documentación)
- [Contribuir](#contribuir)

---

## 🎯 Visión General

### Problema

Los mercados inmobiliarios actuales carecen de plataformas intuitivas que conecten a inquilinos y propietarios de forma segura y eficiente. Las plataformas existentes:

❌ No tienen interfaz visual intuitiva (tipo swipe)
❌ Exponen datos sensibles de los usuarios
❌ No tienen sistema de matching bidireccional
❌ Carecen de comunicación integrada

### Solución

**Real Estate Swipe** es una plataforma MVP que:

✅ Permite a inquilinos deslizar (swipear) propiedades
✅ Propietarios evalúan solicitudes de interés
✅ Matches definitivos generan auto-revelación de documentos sensibles
✅ Chat en tiempo real para coordinación
✅ Privacidad de datos garantizada hasta match

### Modelo de Negocio (Post-MVP)

💰 **Comisión por Match:** 2-5% de la renta mensual
💰 **Verificación Premium:** Plan Pro para propietarios
💰 **Servicios Adicionales:** Seguros, contratos, etc.

---

## ✨ Características Principales

### MVP v1.0

#### 👥 Autenticación y Perfiles

- [x] Registro de usuarios (Tenant/Owner)
- [x] Login con JWT
- [x] Perfiles dinámicos por rol
- [x] Información sensible encriptada

#### 🏘️ Gestión de Propiedades

- [x] CRUD de propiedades (Owner only)
- [x] Upload de fotos/documentos
- [x] Búsqueda y filtros
- [x] Información obligatoria validada

#### 🔄 Sistema de Swipes

- [x] Stack de propiedades (Tenant only)
- [x] Like/Dislike/Later
- [x] Solicitudes de interés
- [x] Sin repetir swipes

#### ⭐ Matches y Privacidad

- [x] Solicitudes de interés (Owner ve perfil sin documentos)
- [x] Matches definitivos
- [x] Auto-revelación de documentos
- [x] Auto-match configurable (Owner)

#### 💬 Chat

- [x] Conversaciones post-match
- [x] Mensajes en tiempo real (WebSocket)
- [x] Historial de mensajes
- [x] Notificaciones

---

## 🔧 Stack Tecnológico

### Backend (Vercel Serverless Functions)

```
Next.js API Routes (Vercel Functions)
├─ TypeScript (Type Safety)
├─ Serverless (Auto-scaling)
├─ Environment Variables
├─ Middleware para auth
├─ Validation (Zod)
└─ PostgreSQL Queries (Supabase)
```

**¿Por qué Vercel?**

- **Same repo:** Frontend + Backend juntos
- **Auto-deploy:** Git push = deployment automático
- **Serverless:** Escalabilidad automática, no DevOps
- **Type-safe:** TypeScript en todo
- **Fast:** Edge functions, CDN global

### Frontend (Next.js + Web)

```
Next.js (App Router)
├─ React (UI Components)
├─ TypeScript (Type Safety)
├─ Tailwind CSS (Styling)
├─ Supabase Auth (Authentication)
└─ Real-time Subscriptions (Chat)
```

### Database (Supabase PostgreSQL)

```
Supabase (Backend-as-a-Service)
├─ PostgreSQL 13+ (Managed)
├─ Supabase Auth (OAuth2, Email, MFA)
├─ Realtime Subscriptions (WebSocket)
├─ Storage (S3-compatible, Encrypted)
├─ RLS Policies (Security)
└─ TypeScript SDK
```

**Stack MVPs Recomendado:**
- Frontend: Next.js deployed on Vercel
- Backend: Vercel Serverless Functions
- Database: Supabase PostgreSQL
- Total Cost: $150-200/mes (Supabase Pro)

---

## 📁 Estructura del Proyecto

```
realestateswipe/
├── database.sql                          # Schema PostgreSQL
├── ARQUITECTURA_Y_API.md                 # Documentación completa
├── BACKEND_SETUP.md                      # Setup del backend
├── IMPLEMENTACION_Y_DEPLOYMENT.md        # Guía de implementación
├── README.md                             # Este archivo
│
├── backend/
│   ├── src/
│   │   ├── config/                      # Configuración (DB, Redis, AWS)
│   │   ├── middleware/                  # Auth, roles, error handling
│   │   ├── routes/                      # Rutas REST
│   │   ├── controllers/                 # Lógica de endpoints
│   │   ├── services/                    # Lógica de negocio
│   │   ├── models/                      # Tipos TypeScript
│   │   ├── utils/                       # JWT, crypto, validators
│   │   ├── websocket/                   # Socket.io events
│   │   ├── jobs/                        # Background jobs
│   │   └── database/                    # Queries parametrizadas
│   ├── tests/
│   │   ├── unit/
│   │   └── integration/
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── .env.example
│
├── mobile/
│   ├── src/
│   │   ├── screens/                     # Pantallas
│   │   ├── components/                  # Componentes reutilizables
│   │   ├── api/                         # Clientes HTTP
│   │   ├── store/                       # Zustand stores
│   │   ├── navigation/                  # Navigadores
│   │   ├── types/                       # TypeScript interfaces
│   │   └── utils/                       # Helpers
│   ├── app.json
│   ├── package.json
│   └── tsconfig.json
│
└── docs/
    ├── API_REFERENCE.md
    ├── DATABASE_SCHEMA.md
    ├── SECURITY.md
    ├── DEPLOYMENT.md
    └── ROADMAP.md
```

---

## 🚀 Guías Rápidas

### Quick Start Backend

```bash
# 1. Clonar repositorio
git clone https://github.com/yourorg/realestateswipe.git
cd realestateswipe/backend

# 2. Instalar dependencias
npm install

# 3. Setup database
createdb realestateswipe
psql realestateswipe < ../database.sql

# 4. Variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# 5. Iniciar servidor
npm run dev

# ✅ API disponible en http://localhost:3000
```

### Quick Start Frontend

```bash
# 1. Crear proyecto React Native
npx react-native init RealEstateSwipe
cd RealEstateSwipe

# 2. Instalar dependencias
npm install

# 3. Copiar estructura de src/
cp -r ../mobile/src ./src

# 4. iOS
cd ios && pod install && cd ..
npm run ios

# 5. Android
npm run android

# ✅ App disponible en emulador/device
```

### Testing

```bash
# Unit tests
npm run test

# Integration tests
npm run test:integration

# Coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

### Deployment

```bash
# Build production
npm run build

# Docker build
docker build -t realestateswipe:1.0.0 .

# Deploy a AWS ECS
# Ver IMPLEMENTACION_Y_DEPLOYMENT.md para detalles completos
```

---

## 📚 Documentación

### Archivos Incluidos

| Archivo | Contenido |
|---------|----------|
| `database.sql` | Schema SQL completo con triggers y funciones |
| `ARQUITECTURA_Y_API.md` | Arquitectura, modelo de datos, endpoints REST |
| `BACKEND_SETUP.md` | Setup del backend, estructura de carpetas, código base |
| `IMPLEMENTACION_Y_DEPLOYMENT.md` | Fases de desarrollo, testing, deployment |
| `README.md` | Este archivo |

### Endpoints Principales

```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh-token

POST   /tenants/profile
POST   /tenants/{id}/guarantor
POST   /owners/profile
PATCH  /owners/{id}/settings

POST   /properties
POST   /properties/{id}/media
GET    /properties
GET    /properties/{id}

GET    /swipe/stack
POST   /swipe

GET    /owner/interest-requests
POST   /owner/interest-requests/{id}/approve
POST   /owner/interest-requests/{id}/decline

GET    /chat/conversations
GET    /chat/conversations/{id}/messages
POST   /chat/conversations/{id}/messages
```

Ver `ARQUITECTURA_Y_API.md` para documentación completa.

---

## 🔐 Seguridad

### Autenticación

- ✅ JWT con Access + Refresh Tokens
- ✅ Contraseñas salted bcrypt (10+ rounds)
- ✅ Token expiration (1h access, 30d refresh)

### Privacidad de Datos

- ✅ Documentos sensibles ocultos hasta match
- ✅ Encriptación end-to-end (TweetNaCl.js)
- ✅ S3 con encriptación en reposo
- ✅ Logs auditados

### API Security

- ✅ HTTPS/TLS obligatorio
- ✅ Rate limiting (5 login/15min, 100 swipes/h)
- ✅ Input validation (Joi)
- ✅ SQL injection prevention (Parameterized queries)
- ✅ CORS configurado

---

## 💾 Database

### Tablas Principales

1. **users** - Base de todos los usuarios
2. **tenant_profiles** - Datos específicos de inquilinos
3. **owner_profiles** - Datos específicos de propietarios
4. **properties** - Anuncios de propiedades
5. **swipes** - Registro de likes/dislikes
6. **matches** - Matches definitivos
7. **chat_conversations** - Conversaciones
8. **chat_messages** - Mensajes individuales
9. **documentation_hub** - Documentos sensibles (encriptados)

### Triggers Automáticos

- Auto-match si owner.auto_match_enabled = true
- Auto-create chat on confirmed match
- Update updated_at timestamps

---

## 🧪 Testing

### Coverage Goal

- **Controllers:** 100%
- **Services:** 100% 
- **Utilities:** 95%
- **Integration:** 80%

### Ejecutar Tests

```bash
# Unit
npm run test:unit

# Integration
npm run test:integration

# All
npm run test

# Specific file
npm run test -- swipe.test.ts

# Watch
npm run test:watch

# Coverage report
npm run test:coverage
```

---

## 📈 Métricas y Monitoreo

### Key Metrics (MVP)

- **Response Time:** < 200ms (p95)
- **Uptime:** > 99.5%
- **Database Connection Pool:** 20 connections
- **Redis Cache Hit Rate:** > 80%
- **WebSocket Connections:** < 5s latency

### Monitoring Stack

- **Logging:** Pino + ELK Stack
- **Error Tracking:** Sentry
- **APM:** DataDog
- **Status Page:** Statuspage.io

---

## 🗺️ Roadmap

### v1.0 (ACTUAL - MVP)
- [x] Autenticación
- [x] Perfiles de usuario
- [x] Gestión de propiedades
- [x] Sistema de swipes
- [x] Matches y chat

### v1.1 (Q3 2026)
- [ ] Sistema de calificaciones
- [ ] Filtros avanzados
- [ ] Búsqueda por ubicación
- [ ] Favoritos

### v2.0 (Q4 2026)
- [ ] Pagos integrados
- [ ] Verificación de identidad
- [ ] Contratos electrónicos
- [ ] Tours virtuales 3D
- [ ] Video llamadas
- [ ] Web app

### v3.0 (2027)
- [ ] Machine Learning para recomendaciones
- [ ] Análisis de precios
- [ ] Marketplace de servicios
- [ ] App para tasadores

---

## 🤝 Contribuir

### Workflow

1. Fork el repositorio
2. Crea una rama: `git checkout -b feature/mi-feature`
3. Commit cambios: `git commit -m 'Add mi-feature'`
4. Push: `git push origin feature/mi-feature`
5. Pull Request

### Código Style

- **TypeScript** strict mode
- **Prettier** formatting
- **ESLint** rules
- **Husky** pre-commit hooks

```bash
# Setup pre-commit
npm install husky --save-dev
npx husky install

# Auto-format antes de commit
npm run lint:fix
```

---

## 📞 Soporte

- **Issues:** GitHub Issues
- **Documentación:** Ver archivos `.md` en root
- **Email:** dev@realestateswipe.com

---

## 📄 Licencia

MIT License - Ver LICENSE.md

---

## 👨‍💼 Autores

**Arquitecto de Soluciones Senior**
- Diseño de arquitectura MVP
- Modelo de datos relacional
- Endpoints REST especificados
- Guía de implementación completa

---

## 🎉 Agradecimientos

Gracias a todas las herramientas de código abierto que hacen posible este proyecto:

- Node.js / Express
- PostgreSQL
- Redis
- Socket.io
- React Native
- Zustand
- Y muchas más...

---

## 📊 Project Status

| Componente | Estado | % Completado |
|-----------|--------|------------|
| Diseño Arquitectónico | ✅ Completado | 100% |
| Schema Database | ✅ Completado | 100% |
| Endpoints Documentados | ✅ Completado | 100% |
| Backend Base Code | ⏳ En progreso | 40% |
| Frontend Móvil | 📋 Planeado | 0% |
| Testing | 📋 Planeado | 0% |
| Deployment | 📋 Planeado | 0% |
| **TOTAL MVP** | ⏳ | **47%** |

---

## 📅 Timeline Estimado

```
Semana 1-2:  Setup Infraestructura           ████████░░ 80%
Semana 3-4:  Endpoints Críticos             ██████░░░░ 60%
Semana 5-6:  Frontend Móvil                 ███░░░░░░░ 30%
Semana 7:    Testing e QA                   ██░░░░░░░░ 20%
Semana 8:    Deployment & Launch            ░░░░░░░░░░ 0%

Total: ~8 semanas para MVP completo
```

---

**Última actualización:** 24 de Junio de 2026

**Stack:** Node.js 18 + PostgreSQL 13 + React Native + Socket.io

**Versión:** 1.0.0-MVP

---

*Construido con ❤️ para el mercado inmobiliario*

# tbr
