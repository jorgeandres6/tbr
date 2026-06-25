# Real Estate Swipe - Backend Project Structure

## Estructura de Carpetas Recomendada

```
realestateswipe-backend/
├── src/
│   ├── config/
│   │   ├── database.ts          # Configuración PostgreSQL
│   │   ├── redis.ts             # Configuración Redis
│   │   ├── aws.ts               # Configuración AWS S3
│   │   └── environment.ts       # Variables de entorno
│   │
│   ├── middleware/
│   │   ├── auth.middleware.ts          # JWT Validation
│   │   ├── roleCheck.middleware.ts     # Role-based access
│   │   ├── errorHandler.middleware.ts  # Global error handler
│   │   ├── rateLimiter.middleware.ts   # Rate limiting
│   │   └── validation.middleware.ts    # Input validation
│   │
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── tenants.routes.ts
│   │   ├── owners.routes.ts
│   │   ├── properties.routes.ts
│   │   ├── swipes.routes.ts
│   │   ├── matches.routes.ts
│   │   └── chat.routes.ts
│   │
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── tenant.controller.ts
│   │   ├── owner.controller.ts
│   │   ├── property.controller.ts
│   │   ├── swipe.controller.ts
│   │   ├── match.controller.ts
│   │   └── chat.controller.ts
│   │
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── tenant.service.ts
│   │   ├── owner.service.ts
│   │   ├── property.service.ts
│   │   ├── swipe.service.ts
│   │   ├── match.service.ts
│   │   ├── chat.service.ts
│   │   ├── document.service.ts
│   │   ├── email.service.ts
│   │   └── notification.service.ts
│   │
│   ├── models/
│   │   ├── types.ts             # TypeScript interfaces
│   │   ├── user.model.ts
│   │   ├── property.model.ts
│   │   ├── swipe.model.ts
│   │   ├── match.model.ts
│   │   └── chat.model.ts
│   │
│   ├── utils/
│   │   ├── jwt.util.ts          # JWT generation/verification
│   │   ├── crypto.util.ts       # Encryption/Decryption
│   │   ├── validators.util.ts   # Input validation functions
│   │   ├── logger.util.ts       # Logging utility
│   │   └── responses.util.ts    # Standard API responses
│   │
│   ├── websocket/
│   │   ├── events.ts            # WebSocket event handlers
│   │   ├── socket.ts            # Socket.io configuration
│   │   └── namespaces/
│   │       └── chat.namespace.ts
│   │
│   ├── jobs/
│   │   ├── expireMatches.job.ts        # Cleanup expired matches
│   │   ├── sendNotifications.job.ts    # Async notifications
│   │   └── archiveChats.job.ts         # Archive old chats
│   │
│   ├── database/
│   │   └── queries/
│   │       ├── user.queries.ts
│   │       ├── property.queries.ts
│   │       ├── swipe.queries.ts
│   │       ├── match.queries.ts
│   │       └── chat.queries.ts
│   │
│   ├── app.ts                   # Express app setup
│   └── index.ts                 # Server entry point
│
├── tests/
│   ├── unit/
│   │   ├── auth.test.ts
│   │   ├── swipe.test.ts
│   │   └── match.test.ts
│   │
│   └── integration/
│       ├── auth.integration.test.ts
│       └── swipe-to-match.integration.test.ts
│
├── migrations/
│   └── 001_initial_schema.sql   # Database migrations
│
├── seeds/
│   └── dev-seed.sql             # Development test data
│
├── .env.example
├── .env.test
├── tsconfig.json
├── package.json
├── jest.config.js
└── README.md
```

---

## Archivo: package.json

```json
{
  "name": "realestateswipe-backend",
  "version": "1.0.0",
  "description": "Backend for Real Estate Swipe App - MVP",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "db:migrate": "node-pg-migrate up",
    "db:seed": "psql -U postgres -d realestateswipe -f seeds/dev-seed.sql",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix"
  },
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "pg": "^8.11.1",
    "redis": "^4.6.10",
    "socket.io": "^4.7.1",
    "jsonwebtoken": "^9.1.0",
    "bcryptjs": "^2.4.3",
    "multer": "^1.4.5-lts.1",
    "@aws-sdk/client-s3": "^3.400.0",
    "@aws-sdk/lib-storage": "^3.400.0",
    "sharp": "^0.32.6",
    "tweetnacl": "^1.0.3",
    "joi": "^17.11.0",
    "bull": "^4.11.4",
    "date-fns": "^2.30.0",
    "axios": "^1.6.0",
    "pino": "^8.16.2",
    "express-rate-limit": "^7.1.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.5.1",
    "@types/jsonwebtoken": "^9.0.2",
    "@types/bcryptjs": "^2.4.2",
    "@types/multer": "^1.4.7",
    "typescript": "^5.1.6",
    "tsx": "^3.14.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.3",
    "ts-jest": "^29.1.1",
    "eslint": "^8.49.0",
    "@typescript-eslint/eslint-plugin": "^6.7.2",
    "@typescript-eslint/parser": "^6.7.2",
    "nodemon": "^3.0.1"
  }
}
```

---

## Archivo: tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "tests", "dist"]
}
```

---

## Archivo: src/types.ts (TypeScript Interfaces)

```typescript
// ============================================================================
// TIPOS PRINCIPALES DE LA APLICACIÓN
// ============================================================================

/**
 * Usuario Base
 */
export interface User {
  user_id: string;
  email: string;
  phone?: string;
  full_name: string;
  profile_picture_url?: string;
  bio?: string;
  role: 'tenant' | 'owner';
  is_active: boolean;
  email_verified: boolean;
  phone_verified: boolean;
  profile_completed: boolean;
  auto_match_enabled: boolean;
  city?: string;
  country_code: string;
  created_at: Date;
  updated_at: Date;
  last_login_at?: Date;
}

/**
 * Perfil de Inquilino
 */
export interface TenantProfile {
  tenant_id: string;
  description: string;
  income_range_id: number;
  occupation?: string;
  years_experience?: number;
  created_at: Date;
  updated_at: Date;
}

/**
 * Avalista
 */
export interface TenantGuarantor {
  guarantor_id: string;
  tenant_id: string;
  full_name: string;
  relationship: string;
  phone?: string;
  email?: string;
  created_at: Date;
}

/**
 * Perfil de Propietario
 */
export interface OwnerProfile {
  owner_id: string;
  business_name?: string;
  company_reg_number?: string;
  verification_status: 'pending' | 'verified' | 'rejected';
  bank_name?: string;
  account_holder_name?: string;
  total_properties_listed: number;
  total_matched_tenants: number;
  average_response_time_minutes?: number;
  created_at: Date;
  updated_at: Date;
}

/**
 * Propiedad (El corazón del MVP)
 */
export interface Property {
  property_id: string;
  owner_id: string;
  title: string;
  description: string;
  price_monthly?: number;
  price_sale?: number;
  area_sqm: number;
  bedrooms: number;
  bathrooms: number;
  floors: number;
  parking_spaces: number;
  floor_number: number;
  has_elevator: boolean;
  pet_friendly: boolean;
  monthly_aliquot?: number;
  amenities: string[];
  extra_areas: string[];
  address: string;
  city: string;
  state_province?: string;
  postal_code?: string;
  latitude?: number;
  longitude?: number;
  country_code: string;
  cover_image_url?: string;
  listing_status: 'active' | 'rented' | 'sold' | 'paused' | 'removed';
  is_visible: boolean;
  view_count: number;
  swipe_count: number;
  created_at: Date;
  updated_at: Date;
}

/**
 * Media de Propiedad
 */
export interface PropertyMedia {
  media_id: string;
  property_id: string;
  media_type: 'image' | 'video' | 'document';
  media_url: string;
  display_order: number;
  uploaded_at: Date;
}

/**
 * Swipe (Like/Dislike)
 */
export interface Swipe {
  swipe_id: string;
  tenant_id: string;
  property_id: string;
  owner_id: string;
  action: 'like' | 'dislike' | 'later';
  request_status: 'pending' | 'owner_viewed' | 'owner_declined';
  request_created_at: Date;
  request_viewed_at?: Date;
  created_at: Date;
}

/**
 * Match Definitivo
 */
export interface Match {
  match_id: string;
  tenant_id: string;
  property_id: string;
  owner_id: string;
  status: 'pending_owner_approval' | 'matched' | 'rejected' | 'expired';
  interest_request_date: Date;
  owner_matched_date?: Date;
  match_confirmed_date?: Date;
  auto_matched: boolean;
  tenant_docs_revealed: boolean;
  owner_docs_revealed: boolean;
  guarantor_info_revealed: boolean;
  expires_at?: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * Chat Conversation
 */
export interface ChatConversation {
  conversation_id: string;
  match_id: string;
  tenant_id: string;
  owner_id: string;
  property_id: string;
  is_active: boolean;
  last_message_at?: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * Chat Message
 */
export interface ChatMessage {
  message_id: string;
  conversation_id: string;
  sender_id: string;
  recipient_id: string;
  message_body: string;
  message_type: 'text' | 'image' | 'document' | 'system';
  attachment_url?: string;
  attachment_mime_type?: string;
  is_read: boolean;
  read_at?: Date;
  created_at: Date;
}

/**
 * Documentación Sensible
 */
export interface DocumentationHub {
  doc_id: string;
  user_id: string;
  id_document_number?: string;
  id_document_type?: 'cedula' | 'pasaporte' | 'carnet';
  id_document_url?: string;
  income_proof_url?: string;
  bank_statement_url?: string;
  employment_letter_url?: string;
  property_id?: string;
  property_title_deed_url?: string;
  property_tax_certificate_url?: string;
  legal_authorization_url?: string;
  is_encrypted: boolean;
  visibility_status: 'private' | 'guarantor_visible' | 'match_visible' | 'public';
  created_at: Date;
  updated_at: Date;
}

/**
 * Auth Response
 */
export interface AuthResponse {
  success: boolean;
  data: {
    user_id: string;
    email: string;
    role: 'tenant' | 'owner';
    access_token: string;
    refresh_token: string;
    expires_in: number;
  };
}

/**
 * API Response Standard
 */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

/**
 * Paginated Response
 */
export interface PaginatedResponse<T> {
  success: boolean;
  data: {
    total: number;
    limit: number;
    offset: number;
    items: T[];
  };
}
```

---

## Archivo: src/utils/responses.util.ts (Response Helper)

```typescript
import { Response } from 'express';

export class ApiResponseHandler {
  static success<T>(res: Response, data: T, statusCode = 200) {
    res.status(statusCode).json({
      success: true,
      data,
    });
  }

  static paginated<T>(
    res: Response,
    items: T[],
    total: number,
    limit: number,
    offset: number,
    statusCode = 200
  ) {
    res.status(statusCode).json({
      success: true,
      data: {
        total,
        limit,
        offset,
        items,
      },
    });
  }

  static error(
    res: Response,
    code: string,
    message: string,
    statusCode = 400,
    details?: Record<string, any>
  ) {
    res.status(statusCode).json({
      success: false,
      error: {
        code,
        message,
        ...(details && { details }),
      },
    });
  }
}
```

---

## Archivo: src/middleware/auth.middleware.ts (JWT Validation)

```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { ApiResponseHandler } from '../utils/responses.util';

export interface AuthRequest extends Request {
  userId?: string;
  userRole?: 'tenant' | 'owner';
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return ApiResponseHandler.error(
        res,
        'NO_TOKEN',
        'Token no proporcionado',
        401
      );
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'secret-key'
    ) as {
      user_id: string;
      role: 'tenant' | 'owner';
    };

    req.userId = decoded.user_id;
    req.userRole = decoded.role;

    next();
  } catch (error) {
    ApiResponseHandler.error(res, 'INVALID_TOKEN', 'Token inválido', 401);
  }
};

export const roleCheck = (allowedRoles: ('tenant' | 'owner')[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.userRole || !allowedRoles.includes(req.userRole)) {
      return ApiResponseHandler.error(
        res,
        'INSUFFICIENT_PERMISSIONS',
        'Solo propietarios pueden acceder a este recurso',
        403
      );
    }
    next();
  };
};
```

---

## Archivo: src/services/auth.service.ts (Autenticación)

```typescript
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Pool } from 'pg';

export class AuthService {
  constructor(private pool: Pool) {}

  /**
   * Registrar nuevo usuario
   */
  async register(
    email: string,
    password: string,
    full_name: string,
    role: 'tenant' | 'owner',
    phone?: string,
    bio?: string
  ) {
    // Validar email único
    const existingUser = await this.pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      throw new Error('EMAIL_ALREADY_EXISTS');
    }

    // Hashear contraseña
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Insertar usuario
    const result = await this.pool.query(
      `INSERT INTO users 
       (email, phone, password_hash, salt, full_name, role, bio)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING user_id, email, role, created_at`,
      [email, phone, passwordHash, salt, full_name, role, bio]
    );

    const user = result.rows[0];

    // Generar tokens
    const accessToken = this.generateAccessToken(user.user_id, role);
    const refreshToken = this.generateRefreshToken(user.user_id);

    return {
      user_id: user.user_id,
      email: user.email,
      role: user.role,
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: 3600, // 1 hora
    };
  }

  /**
   * Login
   */
  async login(email: string, password: string) {
    // Buscar usuario
    const result = await this.pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      throw new Error('INVALID_CREDENTIALS');
    }

    const user = result.rows[0];

    // Validar contraseña
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      throw new Error('INVALID_CREDENTIALS');
    }

    // Actualizar last_login
    await this.pool.query(
      'UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE user_id = $1',
      [user.user_id]
    );

    // Generar tokens
    const accessToken = this.generateAccessToken(user.user_id, user.role);
    const refreshToken = this.generateRefreshToken(user.user_id);

    return {
      user_id: user.user_id,
      email: user.email,
      role: user.role,
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: 3600,
    };
  }

  /**
   * Refresh Token
   */
  refreshToken(refreshToken: string) {
    try {
      const decoded = jwt.verify(
        refreshToken,
        process.env.REFRESH_TOKEN_SECRET || 'refresh-secret'
      ) as {
        user_id: string;
        role: 'tenant' | 'owner';
      };

      const newAccessToken = this.generateAccessToken(
        decoded.user_id,
        decoded.role
      );

      return {
        access_token: newAccessToken,
        expires_in: 3600,
      };
    } catch (error) {
      throw new Error('INVALID_REFRESH_TOKEN');
    }
  }

  /**
   * Generar Access Token (1 hora)
   */
  private generateAccessToken(user_id: string, role: 'tenant' | 'owner') {
    return jwt.sign(
      { user_id, role },
      process.env.JWT_SECRET || 'secret-key',
      { expiresIn: '1h' }
    );
  }

  /**
   * Generar Refresh Token (30 días)
   */
  private generateRefreshToken(user_id: string) {
    return jwt.sign(
      { user_id },
      process.env.REFRESH_TOKEN_SECRET || 'refresh-secret',
      { expiresIn: '30d' }
    );
  }
}
```

---

## Archivo: src/services/swipe.service.ts (Lógica de Swipes)

```typescript
import { Pool } from 'pg';

export class SwipeService {
  constructor(private pool: Pool) {}

  /**
   * Obtener stack de propiedades para swipear (NO SWIPED AÚN)
   */
  async getSwipeStack(tenantId: string, city: string, limit = 10, offset = 0) {
    const query = `
      SELECT 
        p.*,
        json_agg(
          json_build_object(
            'media_id', pm.media_id,
            'media_type', pm.media_type,
            'media_url', pm.media_url
          )
        ) FILTER (WHERE pm.media_id IS NOT NULL) as media
      FROM properties p
      LEFT JOIN properties_media pm ON p.property_id = pm.property_id
      WHERE 
        p.city = $1
        AND p.listing_status = 'active'
        AND p.is_visible = true
        AND p.property_id NOT IN (
          SELECT property_id FROM swipes WHERE tenant_id = $2
        )
      GROUP BY p.property_id
      ORDER BY p.created_at DESC
      LIMIT $3 OFFSET $4
    `;

    const result = await this.pool.query(query, [city, tenantId, limit, offset]);

    const countResult = await this.pool.query(
      `SELECT COUNT(*) FROM properties 
       WHERE city = $1 
       AND listing_status = 'active' 
       AND is_visible = true
       AND property_id NOT IN (SELECT property_id FROM swipes WHERE tenant_id = $2)`,
      [city, tenantId]
    );

    return {
      available_count: parseInt(countResult.rows[0].count),
      stack: result.rows,
    };
  }

  /**
   * Registrar un swipe (Like/Dislike/Later)
   */
  async createSwipe(
    tenantId: string,
    propertyId: string,
    action: 'like' | 'dislike' | 'later'
  ) {
    // Obtener owner_id de la propiedad
    const propertyResult = await this.pool.query(
      'SELECT owner_id FROM properties WHERE property_id = $1',
      [propertyId]
    );

    if (propertyResult.rows.length === 0) {
      throw new Error('PROPERTY_NOT_FOUND');
    }

    const ownerId = propertyResult.rows[0].owner_id;

    // Verificar que no sea propiedad del tenant
    if (tenantId === ownerId) {
      throw new Error('CANNOT_SWIPE_OWN_PROPERTY');
    }

    // Insertar swipe
    const query = `
      INSERT INTO swipes 
      (tenant_id, property_id, owner_id, action, request_status, request_created_at)
      VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    const result = await this.pool.query(query, [
      tenantId,
      propertyId,
      ownerId,
      action,
      action === 'like' ? 'pending' : 'pending',
    ]);

    const swipe = result.rows[0];

    // Si es LIKE, crear notificación para el owner
    if (action === 'like') {
      // TODO: Implementar notificación
    }

    return swipe;
  }

  /**
   * Contar swipes de un usuario
   */
  async countSwipesByUser(tenantId: string, action?: 'like' | 'dislike') {
    let query = 'SELECT COUNT(*) FROM swipes WHERE tenant_id = $1';
    const params: any[] = [tenantId];

    if (action) {
      query += ' AND action = $2';
      params.push(action);
    }

    const result = await this.pool.query(query, params);
    return parseInt(result.rows[0].count);
  }
}
```

---

## Archivo: src/services/match.service.ts (Lógica de Matches)

```typescript
import { Pool } from 'pg';

export class MatchService {
  constructor(private pool: Pool) {}

  /**
   * Obtener solicitudes de interés para un propietario
   */
  async getInterestRequests(ownerId: string, limit = 20, offset = 0) {
    const query = `
      SELECT 
        s.*,
        json_build_object(
          'user_id', u.user_id,
          'full_name', u.full_name,
          'bio', u.bio,
          'profile_picture_url', u.profile_picture_url,
          'description', tp.description,
          'income_range', json_build_object(
            'range_id', ir.range_id,
            'label', ir.label
          ),
          'occupation', tp.occupation,
          'years_experience', tp.years_experience,
          'guarantor', json_build_object(
            'guarantor_id', tg.guarantor_id,
            'full_name', tg.full_name,
            'relationship', tg.relationship,
            'phone', tg.phone,
            'email', tg.email
          )
        ) as tenant_profile
      FROM swipes s
      JOIN users u ON s.tenant_id = u.user_id
      JOIN tenant_profiles tp ON tp.tenant_id = u.user_id
      JOIN income_ranges ir ON ir.range_id = tp.income_range_id
      LEFT JOIN tenant_guarantors tg ON tg.tenant_id = tp.tenant_id
      WHERE 
        s.owner_id = $1 
        AND s.action = 'like'
        AND s.request_status = 'pending'
      ORDER BY s.request_created_at DESC
      LIMIT $2 OFFSET $3
    `;

    const result = await this.pool.query(query, [ownerId, limit, offset]);

    const countResult = await this.pool.query(
      `SELECT COUNT(*) FROM swipes 
       WHERE owner_id = $1 AND action = 'like' AND request_status = 'pending'`,
      [ownerId]
    );

    return {
      total_requests: parseInt(countResult.rows[0].count),
      requests: result.rows,
    };
  }

  /**
   * Aprobar solicitud → CREAR MATCH DEFINITIVO
   * ⚠️ CRÍTICO: AUTO-TRIGGERS documentos revelados + chat
   */
  async approveInterestRequest(swipeId: string, ownerId: string) {
    // Obtener swipe details
    const swipeResult = await this.pool.query(
      'SELECT * FROM swipes WHERE swipe_id = $1 AND owner_id = $2',
      [swipeId, ownerId]
    );

    if (swipeResult.rows.length === 0) {
      throw new Error('SWIPE_NOT_FOUND');
    }

    const swipe = swipeResult.rows[0];

    // Iniciar transacción
    const client = await this.pool.connect();

    try {
      await client.query('BEGIN');

      // 1. Crear Match
      const matchResult = await client.query(
        `INSERT INTO matches 
         (tenant_id, property_id, owner_id, status, 
          interest_request_date, owner_matched_date, match_confirmed_date,
          tenant_docs_revealed, owner_docs_revealed, guarantor_info_revealed)
         VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, true, true, true)
         RETURNING *`,
        [
          swipe.tenant_id,
          swipe.property_id,
          ownerId,
          'matched',
          swipe.request_created_at,
        ]
      );

      const match = matchResult.rows[0];

      // 2. Actualizar swipe status
      await client.query(
        'UPDATE swipes SET request_status = $1 WHERE swipe_id = $2',
        ['owner_viewed', swipeId]
      );

      // 3. Revelar documentos (AUTO-TRIGGER en BD)
      // Esto se maneja con triggers SQL

      // 4. Auto-crear chat (TRIGGER en BD)
      // Esto se maneja con triggers SQL

      await client.query('COMMIT');

      return match;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Rechazar solicitud
   */
  async declineInterestRequest(
    swipeId: string,
    ownerId: string,
    reason?: string
  ) {
    const result = await this.pool.query(
      'UPDATE swipes SET request_status = $1 WHERE swipe_id = $2 AND owner_id = $3 RETURNING *',
      ['owner_declined', swipeId, ownerId]
    );

    if (result.rows.length === 0) {
      throw new Error('SWIPE_NOT_FOUND');
    }

    return result.rows[0];
  }
}
```

---

## Próximos Pasos

1. **Configurar PostgreSQL localmente**
   ```bash
   createdb realestateswipe
   psql realestateswipe < database.sql
   ```

2. **Crear archivo .env**
   ```
   DATABASE_URL=postgresql://user:password@localhost:5432/realestateswipe
   JWT_SECRET=your-secret-key-dev
   REFRESH_TOKEN_SECRET=your-refresh-secret-dev
   REDIS_URL=redis://localhost:6379
   AWS_ACCESS_KEY_ID=xxx
   AWS_SECRET_ACCESS_KEY=xxx
   AWS_S3_BUCKET=realestateswipe-dev
   NODE_ENV=development
   PORT=3000
   ```

3. **Instalar dependencias e iniciar**
   ```bash
   npm install
   npm run dev
   ```

4. **Probar endpoints con Postman**
   - Crear colección con todos los endpoints
   - Testing de flujos completos

---

**Última actualización:** 24 de Junio de 2026
