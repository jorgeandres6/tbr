# 📱 Real Estate Swipe App - Guía de Implementación y Deployment

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Fase de Desarrollo](#fase-de-desarrollo)
3. [Fase de Testing](#fase-de-testing)
4. [Deployment](#deployment)
5. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)
6. [Roadmap Futuro](#roadmap-futuro)

---

## Visión General

### Objetivo del MVP

Crear una plataforma móvil tipo Tinder para el mercado inmobiliario que permita a inquilinos y propietarios conectarse de forma segura y eficiente.

### Principales Características

✅ **Autenticación JWT**
✅ **Perfiles de Usuario** (Tenant + Owner)
✅ **CRUD de Propiedades**
✅ **Sistema de Swipes** (Like/Dislike)
✅ **Solicitudes de Interés**
✅ **Matches con Revelación Automática de Documentos**
✅ **Chat en Tiempo Real** (WebSocket)
✅ **Encriptación de Datos Sensibles**
✅ **Auto-Match Configurable**

---

## Fase de Desarrollo

### Semana 1-2: Setup e Infraestructura

#### 1.1 Backend Setup
```bash
# Crear proyecto
mkdir realestateswipe-backend && cd realestateswipe-backend

# Inicializar Node.js + TypeScript
npm init -y
npm install typescript @types/express @types/node --save-dev
npx tsc --init

# Instalar dependencias
npm install express dotenv cors helmet pg redis socket.io jsonwebtoken bcryptjs multer
npm install --save-dev nodemon tsx

# Estructura de carpetas
mkdir -p src/{config,middleware,routes,controllers,services,models,utils,websocket,database,jobs}
```

#### 1.2 Database Setup

```bash
# PostgreSQL (macOS con Homebrew)
brew install postgresql@15
brew services start postgresql@15

# Crear base de datos
createdb realestateswipe

# Importar schema
psql realestateswipe < database.sql

# Verificar tablas
psql realestateswipe -c "\dt"
```

#### 1.3 Redis Setup

```bash
# Instalar Redis
brew install redis
brew services start redis

# Verificar
redis-cli ping
# Respuesta esperada: PONG
```

#### 1.4 Environment Variables

```bash
# .env (development)
NODE_ENV=development
PORT=3000

DATABASE_URL=postgresql://user:password@localhost:5432/realestateswipe
REDIS_URL=redis://localhost:6379

JWT_SECRET=dev-secret-key-change-in-production
REFRESH_TOKEN_SECRET=dev-refresh-secret-key

# AWS S3 (desarrollo local o fake)
AWS_REGION=us-east-1
AWS_S3_BUCKET=realestateswipe-dev

# Opcional: Usar LocalStack para S3 local
# AWS_S3_ENDPOINT=http://localhost:4566
```

---

### Semana 3-4: Implementación de Endpoints Críticos

#### 3.1 Autenticación

**Archivo:** `src/controllers/auth.controller.ts`

```typescript
import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { ApiResponseHandler } from '../utils/responses.util';
import { Pool } from 'pg';

export class AuthController {
  private authService: AuthService;

  constructor(pool: Pool) {
    this.authService = new AuthService(pool);
  }

  /**
   * POST /auth/register
   */
  async register(req: Request, res: Response) {
    try {
      const { email, password, full_name, role, phone, bio } = req.body;

      // Validaciones básicas
      if (!email || !password || !full_name || !role) {
        return ApiResponseHandler.error(
          res,
          'MISSING_FIELDS',
          'email, password, full_name y role son obligatorios',
          400
        );
      }

      const result = await this.authService.register(
        email,
        password,
        full_name,
        role,
        phone,
        bio
      );

      ApiResponseHandler.success(res, result, 201);
    } catch (error: any) {
      if (error.message === 'EMAIL_ALREADY_EXISTS') {
        return ApiResponseHandler.error(
          res,
          'EMAIL_EXISTS',
          'El email ya está registrado',
          400
        );
      }
      ApiResponseHandler.error(
        res,
        'REGISTER_ERROR',
        'Error durante el registro',
        500
      );
    }
  }

  /**
   * POST /auth/login
   */
  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return ApiResponseHandler.error(
          res,
          'MISSING_FIELDS',
          'email y password son obligatorios',
          400
        );
      }

      const result = await this.authService.login(email, password);
      ApiResponseHandler.success(res, result, 200);
    } catch (error: any) {
      if (error.message === 'INVALID_CREDENTIALS') {
        return ApiResponseHandler.error(
          res,
          'INVALID_CREDENTIALS',
          'Email o contraseña incorrectos',
          401
        );
      }
      ApiResponseHandler.error(res, 'LOGIN_ERROR', 'Error durante login', 500);
    }
  }
}
```

#### 3.2 Rutas

**Archivo:** `src/routes/auth.routes.ts`

```typescript
import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { Pool } from 'pg';

export function authRoutes(pool: Pool) {
  const router = Router();
  const authController = new AuthController(pool);

  router.post('/register', (req, res) => authController.register(req, res));
  router.post('/login', (req, res) => authController.login(req, res));

  return router;
}
```

#### 3.3 Swipes Endpoint

**Archivo:** `src/controllers/swipe.controller.ts`

```typescript
import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { SwipeService } from '../services/swipe.service';
import { ApiResponseHandler } from '../utils/responses.util';
import { Pool } from 'pg';

export class SwipeController {
  private swipeService: SwipeService;

  constructor(pool: Pool) {
    this.swipeService = new SwipeService(pool);
  }

  /**
   * GET /swipe/stack
   */
  async getStack(req: AuthRequest, res: Response) {
    try {
      const { city, limit = 10, offset = 0 } = req.query;

      if (!city) {
        return ApiResponseHandler.error(
          res,
          'MISSING_CITY',
          'city es obligatorio',
          400
        );
      }

      const result = await this.swipeService.getSwipeStack(
        req.userId!,
        city as string,
        parseInt(limit as string),
        parseInt(offset as string)
      );

      ApiResponseHandler.success(res, result, 200);
    } catch (error) {
      ApiResponseHandler.error(
        res,
        'STACK_ERROR',
        'Error obteniendo stack',
        500
      );
    }
  }

  /**
   * POST /swipe
   */
  async createSwipe(req: AuthRequest, res: Response) {
    try {
      const { property_id, action } = req.body;

      if (!property_id || !action) {
        return ApiResponseHandler.error(
          res,
          'MISSING_FIELDS',
          'property_id y action son obligatorios',
          400
        );
      }

      if (!['like', 'dislike', 'later'].includes(action)) {
        return ApiResponseHandler.error(res, 'INVALID_ACTION', 'Acción inválida', 400);
      }

      const result = await this.swipeService.createSwipe(
        req.userId!,
        property_id,
        action
      );

      ApiResponseHandler.success(res, result, 201);
    } catch (error: any) {
      if (error.message === 'PROPERTY_NOT_FOUND') {
        return ApiResponseHandler.error(
          res,
          'PROPERTY_NOT_FOUND',
          'Propiedad no encontrada',
          404
        );
      }
      if (error.message === 'CANNOT_SWIPE_OWN_PROPERTY') {
        return ApiResponseHandler.error(
          res,
          'CANNOT_SWIPE_OWN',
          'No puedes swipear tu propia propiedad',
          400
        );
      }
      ApiResponseHandler.error(res, 'SWIPE_ERROR', 'Error en el swipe', 500);
    }
  }
}
```

---

### Semana 5-6: Frontend Móvil

#### 5.1 React Native Project

```bash
# Crear proyecto React Native
npx react-native init RealEstateSwipe

# Instalar dependencias principales
cd RealEstateSwipe
npm install @react-navigation/native @react-navigation/bottom-tabs @react-navigation/stack
npm install react-native-screens react-native-safe-area-context
npm install axios zustand react-query
npm install react-native-async-storage @react-native-async-storage/async-storage

# Para iOS
cd ios && pod install && cd ..
```

#### 5.2 Estructura del Proyecto

```
RealEstateSwipe/
├── src/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   └── RegisterScreen.tsx
│   │   ├── tenant/
│   │   │   ├── SwipeScreen.tsx
│   │   │   ├── MatchesScreen.tsx
│   │   │   └── ChatScreen.tsx
│   │   └── owner/
│   │       ├── PropertiesScreen.tsx
│   │       ├── RequestsScreen.tsx
│   │       └── ChatScreen.tsx
│   ├── components/
│   │   ├── PropertyCard.tsx
│   │   ├── SwipeButton.tsx
│   │   ├── ChatBubble.tsx
│   │   └── LoadingSpinner.tsx
│   ├── api/
│   │   ├── client.ts
│   │   ├── auth.api.ts
│   │   ├── properties.api.ts
│   │   ├── swipes.api.ts
│   │   ├── matches.api.ts
│   │   └── chat.api.ts
│   ├── store/
│   │   ├── authStore.ts
│   │   ├── propertyStore.ts
│   │   └── chatStore.ts
│   ├── types/
│   │   └── index.ts
│   ├── utils/
│   │   ├── validation.ts
│   │   └── storage.ts
│   ├── navigation/
│   │   ├── AuthNavigator.tsx
│   │   ├── TenantNavigator.tsx
│   │   ├── OwnerNavigator.tsx
│   │   └── RootNavigator.tsx
│   └── App.tsx
├── app.json
├── package.json
└── tsconfig.json
```

#### 5.3 API Client

**Archivo:** `src/api/client.ts`

```typescript
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'https://api.realestateswipe.com/v1';

const client = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Interceptor para agregar token a cada request
client.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor para manejar 401 (token expirado)
client.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = await AsyncStorage.getItem('refreshToken');
        const response = await axios.post(`${API_BASE_URL}/auth/refresh-token`, {
          refresh_token: refreshToken,
        });

        const { access_token } = response.data.data;
        await AsyncStorage.setItem('accessToken', access_token);

        originalRequest.headers.Authorization = `Bearer ${access_token}`;
        return client(originalRequest);
      } catch (err) {
        await AsyncStorage.removeItem('accessToken');
        await AsyncStorage.removeItem('refreshToken');
        // Redirigir a login
      }
    }

    return Promise.reject(error);
  }
);

export default client;
```

#### 5.4 Zustand Store

**Archivo:** `src/store/authStore.ts`

```typescript
import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthStore {
  userId: string | null;
  email: string | null;
  role: 'tenant' | 'owner' | null;
  accessToken: string | null;
  refreshToken: string | null;
  isLoading: boolean;

  // Actions
  setAuth: (data: Partial<AuthStore>) => void;
  logout: () => void;
  restoreToken: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>((set) => ({
  userId: null,
  email: null,
  role: null,
  accessToken: null,
  refreshToken: null,
  isLoading: true,

  setAuth: (data) => set(data),

  logout: async () => {
    await AsyncStorage.removeItem('accessToken');
    await AsyncStorage.removeItem('refreshToken');
    set({
      userId: null,
      email: null,
      role: null,
      accessToken: null,
      refreshToken: null,
    });
  },

  restoreToken: async () => {
    try {
      const token = await AsyncStorage.getItem('accessToken');
      const userId = await AsyncStorage.getItem('userId');
      const role = await AsyncStorage.getItem('role');

      if (token && userId) {
        set({
          accessToken: token,
          userId,
          role: role as 'tenant' | 'owner',
        });
      }
    } catch (e) {
      console.error('Failed to restore token:', e);
    }
    set({ isLoading: false });
  },
}));
```

---

## Fase de Testing

### Unit Tests

**Archivo:** `tests/unit/swipe.test.ts`

```typescript
import { SwipeService } from '../../src/services/swipe.service';
import { Pool } from 'pg';

describe('SwipeService', () => {
  let pool: Pool;
  let swipeService: SwipeService;

  beforeEach(() => {
    // Mock pool
    pool = {
      query: jest.fn(),
    } as any;
    swipeService = new SwipeService(pool);
  });

  describe('createSwipe', () => {
    it('should create a like swipe successfully', async () => {
      const tenantId = 'tenant-123';
      const propertyId = 'prop-456';
      const ownerId = 'owner-789';

      (pool.query as jest.Mock)
        .mockResolvedValueOnce({ rows: [{ owner_id: ownerId }] }) // Property query
        .mockResolvedValueOnce({
          rows: [
            {
              swipe_id: 'swipe-001',
              tenant_id: tenantId,
              property_id: propertyId,
              action: 'like',
            },
          ],
        }); // Insert query

      const result = await swipeService.createSwipe(
        tenantId,
        propertyId,
        'like'
      );

      expect(result.action).toBe('like');
      expect(result.request_status).toBe('pending');
    });

    it('should throw error if property not found', async () => {
      (pool.query as jest.Mock).mockResolvedValueOnce({ rows: [] });

      await expect(
        swipeService.createSwipe('tenant-123', 'prop-999', 'like')
      ).rejects.toThrow('PROPERTY_NOT_FOUND');
    });
  });
});
```

### Integration Tests

**Archivo:** `tests/integration/swipe-to-match.integration.test.ts`

```typescript
describe('Swipe to Match Flow', () => {
  let server: any;
  let pool: Pool;

  beforeAll(async () => {
    // Setup test server
    // Connect to test database
  });

  afterAll(async () => {
    // Cleanup
  });

  it('should complete full swipe-to-match flow', async () => {
    // 1. Create tenant user
    const tenantRes = await request(server)
      .post('/auth/register')
      .send({
        email: 'tenant@test.com',
        password: 'pass123',
        full_name: 'Test Tenant',
        role: 'tenant',
      });

    const tenantToken = tenantRes.body.data.access_token;

    // 2. Create owner user
    const ownerRes = await request(server)
      .post('/auth/register')
      .send({
        email: 'owner@test.com',
        password: 'pass123',
        full_name: 'Test Owner',
        role: 'owner',
      });

    const ownerToken = ownerRes.body.data.access_token;

    // 3. Owner creates property
    const propertyRes = await request(server)
      .post('/properties')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        title: 'Test Property',
        price_monthly: 1500,
        // ... other properties
      });

    const propertyId = propertyRes.body.data.property_id;

    // 4. Tenant swipes like
    const swipeRes = await request(server)
      .post('/swipe')
      .set('Authorization', `Bearer ${tenantToken}`)
      .send({
        property_id: propertyId,
        action: 'like',
      });

    expect(swipeRes.status).toBe(201);
    expect(swipeRes.body.data.request_status).toBe('pending');

    // 5. Owner approves request
    const matchRes = await request(server)
      .post(`/owner/interest-requests/${swipeRes.body.data.swipe_id}/approve`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({});

    expect(matchRes.status).toBe(200);
    expect(matchRes.body.data.status).toBe('matched');
    expect(matchRes.body.data.tenant_docs_revealed).toBe(true);

    // 6. Verify chat was created
    const chatRes = await request(server)
      .get('/chat/conversations')
      .set('Authorization', `Bearer ${tenantToken}`);

    expect(chatRes.body.data.conversations.length).toBeGreaterThan(0);
  });
});
```

---

## Deployment

### 1. Preparar para Producción

#### 1.1 Environment Variables (Producción)

```bash
# .env.production
NODE_ENV=production
PORT=3000

DATABASE_URL=postgresql://prod_user:secure_pass@prod-db.aws.com:5432/realestateswipe
REDIS_URL=redis://prod-redis.aws.com:6379

JWT_SECRET=use-super-secure-key-from-vault
REFRESH_TOKEN_SECRET=another-secure-key-from-vault

AWS_REGION=us-east-1
AWS_S3_BUCKET=realestateswipe-prod

# Sentry (error tracking)
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx

# Database SSL
DATABASE_SSL=true
```

#### 1.2 Build Backend

```bash
# Build TypeScript
npm run build

# Test producción localmente
npm start
```

#### 1.3 Build Frontend

```bash
# iOS
cd ios
pod install
cd ..
xcode-select --install
npm run build:ios

# Android
# Generar signed APK
cd android
./gradlew bundleRelease
```

### 2. Deployment en AWS

#### 2.1 Elastic Container Service (ECS)

**Dockerfile:**

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy built code
COPY dist ./dist

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start app
CMD ["node", "dist/index.js"]
```

**Build and Push:**

```bash
# Build image
docker build -t realestateswipe-backend:1.0.0 .

# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin xxxxx.dkr.ecr.us-east-1.amazonaws.com

docker tag realestateswipe-backend:1.0.0 xxxxx.dkr.ecr.us-east-1.amazonaws.com/realestateswipe-backend:1.0.0

docker push xxxxx.dkr.ecr.us-east-1.amazonaws.com/realestateswipe-backend:1.0.0
```

#### 2.2 Database Migration

```bash
# Backup producción
pg_dump -h prod-db.aws.com -U prod_user realestateswipe > backup_prod.sql

# Ejecutar migraciones
psql -h prod-db.aws.com -U prod_user -d realestateswipe < database.sql
```

#### 2.3 SSL Certificate

```bash
# Usar AWS Certificate Manager
# O generar con Let's Encrypt + Nginx
```

### 3. Aplicación Móvil

#### 3.1 iOS AppStore

```bash
# Generar certificados de distribución
# En Xcode: Signing & Capabilities

# Build para distribution
xcode-select --install
npm run build:ios

# Usar Application Loader o Transporter para subir a AppStore Connect
```

#### 3.2 Google Play Store

```bash
# Generar key store
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release

# Build APK/Bundle
npm run build:android

# Upload a Google Play Console
```

---

## Monitoreo y Mantenimiento

### 1. Logging y Observabilidad

```typescript
// src/utils/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport:
    process.env.NODE_ENV === 'production'
      ? undefined
      : {
          target: 'pino-pretty',
          options: {
            colorize: true,
          },
        },
});

// Usar en servicios
logger.info({ userId: '123' }, 'User logged in');
logger.error({ error }, 'Database connection failed');
```

### 2. Error Tracking (Sentry)

```typescript
import * as Sentry from "@sentry/node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

// Middleware
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.errorHandler());
```

### 3. Performance Monitoring

```typescript
// Track expensive operations
import { performance } from 'perf_hooks';

async function getSwipeStack(...) {
  const start = performance.now();
  
  // ... operation
  
  const duration = performance.now() - start;
  logger.info({ duration }, 'getSwipeStack took');
  
  if (duration > 1000) {
    // Alert on slow queries
  }
}
```

### 4. Database Maintenance

```sql
-- Weekly: Vacuum and Analyze
VACUUM ANALYZE;

-- Monitor table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check slow queries
SELECT 
  query,
  mean_exec_time,
  calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## Roadmap Futuro

### v1.1 (Post-MVP)

- [ ] Sistema de calificaciones (⭐)
- [ ] Reseñas de usuarios
- [ ] Filtros avanzados (rango de precios deslizable)
- [ ] Búsqueda por ubicación geográfica
- [ ] Guardar favoritos ("Later")

### v2.0 (Q3 2026)

- [ ] Pagos integrados (Stripe/PayU)
- [ ] Verificación de identidad (Onfido)
- [ ] Contratos electrónicos (DocuSign)
- [ ] Tours virtuales 3D
- [ ] Video llamadas integradas
- [ ] Aplicación Web (Next.js)

### v3.0 (Q4 2026)

- [ ] Machine Learning para recomendaciones
- [ ] Análisis de precios inmobiliarios
- [ ] Seguros de vivienda integrados
- [ ] Marketplace de servicios (inspecciones, mudanzas)
- [ ] App para tasadores/avalistas

---

## Checklist de Deployment

### Pre-Launch

- [ ] Todos los tests pasando (100% coverage mínimo en rutas críticas)
- [ ] Code review completado
- [ ] Security scan (OWASP Top 10)
- [ ] Performance testing (load testing con Artillery/Locust)
- [ ] SSL/TLS configurado
- [ ] Backups automatizados
- [ ] Disaster recovery plan
- [ ] Privacy policy aceptado (GDPR)
- [ ] Terms of Service publicados
- [ ] Rate limiting activado
- [ ] Logging y monitoring configurados
- [ ] Analytics integrado

### Post-Launch

- [ ] Monitoreo 24/7 activado
- [ ] Alertas configuradas
- [ ] Runbooks preparados
- [ ] Proceso de rollback documentado
- [ ] Status page pública (Statuspage.io)

---

**Última actualización:** 24 de Junio de 2026  
**Versión:** 1.0.0  
**Autor:** Senior Software Engineer

