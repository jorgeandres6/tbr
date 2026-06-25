-- ============================================================================
-- REAL ESTATE SWIPE APP - DATABASE SCHEMA
-- MVP (Minimum Viable Product)
-- ============================================================================
-- Este script crea la estructura completa de la base de datos PostgreSQL
-- para la aplicación de bienes raíces con lógica de swipe (Tinder-like)
-- ============================================================================

-- Extensiones requeridas
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para búsqueda full-text en propiedades

-- ============================================================================
-- 1. TABLA: USERS (Usuarios - Base para Tenants y Owners)
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  salt VARCHAR(255) NOT NULL,
  
  -- Información de Perfil
  full_name VARCHAR(255) NOT NULL,
  profile_picture_url TEXT,
  bio TEXT,
  
  -- Rol del Usuario
  role VARCHAR(20) NOT NULL CHECK (role IN ('tenant', 'owner')),
  
  -- Estado de Cuenta
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false,
  profile_completed BOOLEAN DEFAULT false,
  
  -- Configuración
  auto_match_enabled BOOLEAN DEFAULT false, -- Solo para owners
  notifications_enabled BOOLEAN DEFAULT true,
  
  -- Localización (para búsquedas futuras)
  city VARCHAR(100),
  country_code VARCHAR(3) DEFAULT 'COL',
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_city ON users(city);
CREATE INDEX idx_users_active ON users(is_active);

-- ============================================================================
-- 2. TABLA: INCOME_RANGES (Rangos de Ingresos - Lookup)
-- ============================================================================
CREATE TABLE IF NOT EXISTS income_ranges (
  range_id SERIAL PRIMARY KEY,
  label VARCHAR(100) UNIQUE NOT NULL,
  min_amount DECIMAL(10,2) NOT NULL,
  max_amount DECIMAL(10,2),
  description TEXT
);

INSERT INTO income_ranges (label, min_amount, max_amount, description) 
VALUES 
  ('$0-$500', 0, 500, 'Menos de $500 mensuales'),
  ('$500-$1000', 500, 1000, 'Entre $500 y $1000'),
  ('$1000-$2000', 1000, 2000, 'Entre $1000 y $2000'),
  ('$2000-$5000', 2000, 5000, 'Entre $2000 y $5000'),
  ('$5000+', 5000, NULL, 'Más de $5000 mensuales')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 3. TABLA: TENANT_PROFILES (Perfiles de Inquilinos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS tenant_profiles (
  tenant_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Campos Obligatorios
  description TEXT NOT NULL, -- "Busco apartamento con balcón en Zona Norte"
  income_range_id INTEGER NOT NULL REFERENCES income_ranges(range_id),
  
  -- Campos Opcionales
  occupation VARCHAR(255),
  years_experience INTEGER,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tenant_profiles_income_range ON tenant_profiles(income_range_id);

-- ============================================================================
-- 4. TABLA: TENANT_GUARANTORS (Avalistas del Inquilino)
-- ============================================================================
CREATE TABLE IF NOT EXISTS tenant_guarantors (
  guarantor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenant_profiles(tenant_id) ON DELETE CASCADE,
  
  -- Información del Avalista
  full_name VARCHAR(255) NOT NULL,
  relationship VARCHAR(100), -- "Padre", "Madre", "Hermano", "Amigo"
  phone VARCHAR(20),
  email VARCHAR(255),
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT unique_guarantor_per_tenant UNIQUE (tenant_id, guarantor_id)
);

CREATE INDEX idx_guarantors_tenant ON tenant_guarantors(tenant_id);

-- ============================================================================
-- 5. TABLA: OWNER_PROFILES (Perfiles de Propietarios)
-- ============================================================================
CREATE TABLE IF NOT EXISTS owner_profiles (
  owner_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Información del Negocio
  business_name VARCHAR(255),
  company_reg_number VARCHAR(100), -- RUC, NIT, etc.
  verification_status VARCHAR(20) DEFAULT 'pending' 
    CHECK (verification_status IN ('pending', 'verified', 'rejected')),
  
  -- Información Bancaria (ENCRIPTADA)
  bank_name VARCHAR(255),
  account_number_hash VARCHAR(255), -- NUNCA guardar en texto plano
  account_holder_name VARCHAR(255),
  
  -- Estadísticas
  total_properties_listed INTEGER DEFAULT 0,
  total_matched_tenants INTEGER DEFAULT 0,
  average_response_time_minutes INTEGER,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. TABLA: PROPERTIES (Propiedades - NÚCLEO DEL MVP)
-- ============================================================================
CREATE TABLE IF NOT EXISTS properties (
  property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES owner_profiles(owner_id) ON DELETE CASCADE,
  
  -- Información Básica (MANDATORY)
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  price_monthly DECIMAL(10,2), -- Renta
  price_sale DECIMAL(12,2), -- Venta
  
  -- Especificaciones Físicas (MANDATORY)
  area_sqm DECIMAL(8,2) NOT NULL,
  bedrooms INTEGER NOT NULL,
  bathrooms INTEGER NOT NULL,
  floors INTEGER NOT NULL,
  parking_spaces INTEGER NOT NULL,
  floor_number INTEGER NOT NULL,
  
  -- Características
  has_elevator BOOLEAN NOT NULL DEFAULT false,
  pet_friendly BOOLEAN NOT NULL DEFAULT false,
  monthly_aliquot DECIMAL(8,2), -- Cuota de condominio
  
  -- Amenities (JSONB para flexibilidad)
  amenities JSONB DEFAULT '[]', 
  -- Ejemplo: ["piscina", "gimnasio", "parque", "seguridad 24/7"]
  
  -- Áreas Extra (JSONB)
  extra_areas JSONB DEFAULT '[]',
  -- Ejemplo: ["bodega", "cuarto de servicios", "balcón grande"]
  
  -- Ubicación (MANDATORY)
  address VARCHAR(500) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state_province VARCHAR(100),
  postal_code VARCHAR(20),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  country_code VARCHAR(3) DEFAULT 'COL',
  
  -- Media
  cover_image_url TEXT,
  
  -- Estado del Anuncio
  listing_status VARCHAR(20) DEFAULT 'active' 
    CHECK (listing_status IN ('active', 'rented', 'sold', 'paused', 'removed')),
  is_visible BOOLEAN DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  view_count INTEGER DEFAULT 0,
  swipe_count INTEGER DEFAULT 0,
  
  -- Validaciones
  CONSTRAINT at_least_one_price CHECK (
    (price_monthly IS NOT NULL AND price_monthly > 0) 
    OR (price_sale IS NOT NULL AND price_sale > 0)
  ),
  CONSTRAINT area_positive CHECK (area_sqm > 0),
  CONSTRAINT rooms_positive CHECK (bedrooms > 0),
  CONSTRAINT baths_positive CHECK (bathrooms > 0),
  CONSTRAINT parking_non_negative CHECK (parking_spaces >= 0),
  CONSTRAINT aliquot_non_negative CHECK (monthly_aliquot >= 0)
);

CREATE INDEX idx_properties_owner ON properties(owner_id);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_status ON properties(listing_status);
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
CREATE INDEX idx_properties_price ON properties(price_monthly, price_sale);
CREATE INDEX idx_properties_specs ON properties(bedrooms, bathrooms, area_sqm);

-- ============================================================================
-- 7. TABLA: PROPERTIES_MEDIA (Fotos y Videos de Propiedades)
-- ============================================================================
CREATE TABLE IF NOT EXISTS properties_media (
  media_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  
  media_type VARCHAR(20) NOT NULL CHECK (media_type IN ('image', 'video', 'document')),
  media_url TEXT NOT NULL,
  display_order INTEGER DEFAULT 0,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT display_order_non_negative CHECK (display_order >= 0)
);

CREATE INDEX idx_properties_media_property ON properties_media(property_id);
CREATE INDEX idx_properties_media_type ON properties_media(media_type);

-- ============================================================================
-- 8. TABLA: DOCUMENTATION_HUB (Datos Sensibles y Encriptados)
-- ============================================================================
CREATE TABLE IF NOT EXISTS documentation_hub (
  doc_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Documentos del Inquilino
  id_document_number VARCHAR(50), -- ENCRIPTADO
  id_document_type VARCHAR(20) CHECK (id_document_type IN ('cedula', 'pasaporte', 'carnet')),
  id_document_url TEXT, -- S3 URL (contenido encriptado)
  
  income_proof_url TEXT,
  bank_statement_url TEXT,
  employment_letter_url TEXT,
  
  -- Documentos del Propietario (Relacionados con propiedad)
  property_id UUID REFERENCES properties(property_id) ON DELETE CASCADE,
  property_title_deed_url TEXT, -- Escritura
  property_tax_certificate_url TEXT,
  legal_authorization_url TEXT, -- Poder notarial
  
  -- Seguridad
  is_encrypted BOOLEAN DEFAULT true,
  encryption_key_salt VARCHAR(255),
  
  -- Control de Acceso
  visibility_status VARCHAR(30) DEFAULT 'private'
    CHECK (visibility_status IN ('private', 'guarantor_visible', 'match_visible', 'public')),
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_doc_hub_user ON documentation_hub(user_id);
CREATE INDEX idx_doc_hub_property ON documentation_hub(property_id);
CREATE INDEX idx_doc_hub_visibility ON documentation_hub(visibility_status);

-- ============================================================================
-- 9. TABLA: SWIPES (Acciones de Swipe - El Corazón del MVP)
-- ============================================================================
CREATE TABLE IF NOT EXISTS swipes (
  swipe_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Acción del Swipe
  action VARCHAR(10) NOT NULL CHECK (action IN ('like', 'dislike', 'later')),
  
  -- Estado de la Solicitud (si es "like")
  request_status VARCHAR(20) DEFAULT 'pending'
    CHECK (request_status IN ('pending', 'owner_viewed', 'owner_declined')),
  
  -- Timestamps
  request_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  request_viewed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Restricciones
  CONSTRAINT unique_swipe_per_user_property UNIQUE (tenant_id, property_id),
  CONSTRAINT tenant_owner_different CHECK (tenant_id != owner_id),
  CONSTRAINT request_status_valid CHECK (
    (action = 'like') OR (action != 'like' AND request_status = 'pending')
  )
);

CREATE INDEX idx_swipes_tenant ON swipes(tenant_id);
CREATE INDEX idx_swipes_property ON swipes(property_id);
CREATE INDEX idx_swipes_owner ON swipes(owner_id);
CREATE INDEX idx_swipes_action ON swipes(action);
CREATE INDEX idx_swipes_request_status ON swipes(request_status);
CREATE INDEX idx_swipes_created ON swipes(created_at);

-- ============================================================================
-- 10. TABLA: MATCHES (Match Definitivo - RUTA CRÍTICA)
-- ============================================================================
CREATE TABLE IF NOT EXISTS matches (
  match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Estado del Match
  status VARCHAR(30) DEFAULT 'pending_owner_approval'
    CHECK (status IN ('pending_owner_approval', 'matched', 'rejected', 'expired')),
  
  -- Timeline
  interest_request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  owner_matched_date TIMESTAMP,
  match_confirmed_date TIMESTAMP,
  expires_at TIMESTAMP,
  
  -- Flags
  auto_matched BOOLEAN DEFAULT false,
  
  -- Revelación de Documentos (CRUCIAL PARA PRIVACIDAD)
  tenant_docs_revealed BOOLEAN DEFAULT false,
  owner_docs_revealed BOOLEAN DEFAULT false,
  guarantor_info_revealed BOOLEAN DEFAULT false,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Restricciones
  CONSTRAINT unique_match_per_tenant_property UNIQUE (tenant_id, property_id),
  CONSTRAINT tenant_owner_different_match CHECK (tenant_id != owner_id),
  CONSTRAINT matched_requires_dates CHECK (
    (status = 'matched' AND match_confirmed_date IS NOT NULL) OR status != 'matched'
  )
);

CREATE INDEX idx_matches_tenant ON matches(tenant_id);
CREATE INDEX idx_matches_property ON matches(property_id);
CREATE INDEX idx_matches_owner ON matches(owner_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_dates ON matches(created_at, match_confirmed_date);

-- ============================================================================
-- 11. TABLA: CHAT_CONVERSATIONS (Conversaciones - Post-Match)
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_conversations (
  conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID NOT NULL UNIQUE REFERENCES matches(match_id) ON DELETE CASCADE,
  
  tenant_id UUID NOT NULL REFERENCES users(user_id),
  owner_id UUID NOT NULL REFERENCES users(user_id),
  property_id UUID NOT NULL REFERENCES properties(property_id),
  
  -- Estado
  is_active BOOLEAN DEFAULT true,
  last_message_at TIMESTAMP,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Restricción
  CONSTRAINT tenant_owner_different_chat CHECK (tenant_id != owner_id)
);

CREATE INDEX idx_chat_conversations_tenant ON chat_conversations(tenant_id);
CREATE INDEX idx_chat_conversations_owner ON chat_conversations(owner_id);
CREATE INDEX idx_chat_conversations_match ON chat_conversations(match_id);
CREATE INDEX idx_chat_conversations_active ON chat_conversations(is_active);

-- ============================================================================
-- 12. TABLA: CHAT_MESSAGES (Mensajes en Chat - Synced con WebSocket)
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
  message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES chat_conversations(conversation_id) ON DELETE CASCADE,
  
  sender_id UUID NOT NULL REFERENCES users(user_id),
  recipient_id UUID NOT NULL REFERENCES users(user_id),
  
  message_body TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'document', 'system')),
  
  -- Attachments (opcional)
  attachment_url TEXT,
  attachment_mime_type VARCHAR(100),
  
  -- Read Status
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Restricción
  CONSTRAINT sender_recipient_different CHECK (sender_id != recipient_id)
);

CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_read ON chat_messages(is_read);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at);

-- ============================================================================
-- TRIGGERS Y FUNCIONES AUTOMÁTICAS
-- ============================================================================

-- Función: Actualizar 'updated_at' automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas principales
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at
  BEFORE UPDATE ON matches
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_conversations_updated_at
  BEFORE UPDATE ON chat_conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCIÓN: Auto-Match cuando se crea un swipe
-- ============================================================================
CREATE OR REPLACE FUNCTION auto_match_if_enabled()
RETURNS TRIGGER AS $$
DECLARE
  owner_auto_match BOOLEAN;
  match_record RECORD;
BEGIN
  -- Solo procesar si es un "like"
  IF NEW.action = 'like' THEN
    -- Verificar si el owner tiene auto_match_enabled
    SELECT u.auto_match_enabled INTO owner_auto_match
    FROM users u
    WHERE u.user_id = NEW.owner_id;
    
    -- Si está habilitado, crear match automáticamente
    IF owner_auto_match THEN
      INSERT INTO matches (
        tenant_id, property_id, owner_id,
        status, auto_matched,
        tenant_docs_revealed, owner_docs_revealed, guarantor_info_revealed
      )
      VALUES (
        NEW.tenant_id, NEW.property_id, NEW.owner_id,
        'matched', true,
        true, true, true
      )
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_match_on_swipe
  AFTER INSERT ON swipes
  FOR EACH ROW
  EXECUTE FUNCTION auto_match_if_enabled();

-- ============================================================================
-- FUNCIÓN: Crear chat automáticamente cuando se confirma un match
-- ============================================================================
CREATE OR REPLACE FUNCTION create_chat_on_match()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'matched' AND OLD.status != 'matched' THEN
    INSERT INTO chat_conversations (
      match_id, tenant_id, owner_id, property_id, is_active
    )
    VALUES (
      NEW.match_id, NEW.tenant_id, NEW.owner_id, NEW.property_id, true
    )
    ON CONFLICT DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_chat_on_match
  AFTER UPDATE ON matches
  FOR EACH ROW
  EXECUTE FUNCTION create_chat_on_match();

-- ============================================================================
-- VISTAS ÚTILES PARA CONSULTAS FRECUENTES
-- ============================================================================

-- Vista: Propiedades disponibles para swipe (no swiped por un tenant)
CREATE OR REPLACE VIEW available_properties_for_tenant AS
SELECT 
  p.property_id,
  p.owner_id,
  p.title,
  p.description,
  p.price_monthly,
  p.area_sqm,
  p.bedrooms,
  p.bathrooms,
  p.city,
  p.cover_image_url,
  p.created_at
FROM properties p
WHERE p.listing_status = 'active' AND p.is_visible = true;

-- Vista: Estadísticas de matches por owner
CREATE OR REPLACE VIEW owner_match_statistics AS
SELECT 
  o.owner_id,
  u.full_name,
  o.business_name,
  COUNT(DISTINCT m.match_id) as total_matches,
  COUNT(DISTINCT m.match_id) FILTER (WHERE m.status = 'matched') as active_matches,
  COUNT(DISTINCT m.match_id) FILTER (WHERE m.status = 'pending_owner_approval') as pending_matches,
  COUNT(DISTINCT p.property_id) as total_properties_listed
FROM owner_profiles o
LEFT JOIN users u ON o.owner_id = u.user_id
LEFT JOIN matches m ON o.owner_id = m.owner_id
LEFT JOIN properties p ON o.owner_id = p.owner_id
GROUP BY o.owner_id, u.full_name, o.business_name;

-- ============================================================================
-- COMENTARIOS FINALES
-- ============================================================================
/*
NOTAS IMPORTANTES:

1. ENCRIPTACIÓN:
   - Las URLs de documentos en S3 contienen datos encriptados
   - Implementar encriptación end-to-end en frontend
   - Nunca guardar contraseñas o tokens en base de datos (usar JWT)

2. PERFORMANCES:
   - Los índices están optimizados para queries comunes
   - Usar Redis para caché de stacks de swipe
   - Paginar siempre los resultados

3. SEGURIDAD:
   - Implementar Row-Level Security (RLS) en PostgreSQL si es posible
   - Validar permisos en backend antes de revelar documentos
   - Usar salted hashes para contraseñas

4. SCALABILITY:
   - Considerar partitioning para tabla 'swipes' y 'chat_messages'
   - Usar materialized views para estadísticas
   - Implementar archivamiento de chats antiguos

5. COMPLIANCE:
   - GDPR: Derecho al olvido (soft delete de datos sensibles)
   - Auditoría: Loguear accesos a documentos sensibles
   - Consentimiento: Permitir opt-out de feature comerciales
*/
