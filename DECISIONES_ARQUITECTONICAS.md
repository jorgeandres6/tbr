# 🏗️ Decisiones Arquitectónicas - Real Estate Swipe MVP

## Documento de Justificación de Arquitectura

**Versión:** 1.0  
**Fecha:** 24 de Junio de 2026  
**Preparado para:** Stakeholders técnicos y de negocio

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Criterios de Decisión](#criterios-de-decisión)
3. [Decisiones Principales](#decisiones-principales)
4. [Trade-offs](#trade-offs)
5. [Riesgos Mitigados](#riesgos-mitigados)

---

## 📋 Resumen Ejecutivo

### Contexto

Se requiere diseñar una arquitectura MVP para una aplicación móvil tipo Tinder para bienes raíces. Debe soportar:

- Múltiples roles de usuario (Tenant/Owner)
- Lógica de matching bidireccional
- Privacidad de datos sensibles hasta match definitivo
- Chat en tiempo real
- Operación en bajo costo inicialmente con capacidad de escalar

### Arquitectura Propuesta

```
┌─────────────────────────────────────────────────────────┐
│                  CLIENTE MÓVIL                          │
│            (React Native / Flutter)                     │
└────────────────────┬────────────────────────────────────┘
                     │ REST + WebSocket
         ┌───────────┴──────────────┐
         ▼                          ▼
    ┌─────────────────────────┐ ┌──────────────┐
    │    BACKEND              │ │ ALMACENAMIENTO
    │  Node.js + Express      │ │  AWS S3 +
    │  (TypeScript)           │ │  CloudFront
    │                         │ │
    │ • Autenticación JWT     │ └──────────────┘
    │ • REST API              │
    │ • Socket.io (Chat)      │ ┌──────────────┐
    │ • Validación            │ │ CACHÉ        │
    │ • Lógica de negocio     │ │ Redis        │
    └────────────┬────────────┘ │ • Sessions   │
                 │               │ • Stack      │
         ┌───────┴────────┐      │   cache     │
         ▼                ▼      └──────────────┘
    ┌──────────────────────────────────┐
    │       POSTGRESQL 13+              │
    │   (Relational Database)           │
    │                                   │
    │ • Users, Properties, Matches      │
    │ • Swipes, Chat                    │
    │ • Triggers automáticos            │
    │ • Full-text search                │
    └──────────────────────────────────┘
```

### Beneficios Clave

✅ **Escalabilidad horizontal:** Node.js stateless, múltiples instancias  
✅ **Tiempo real:** WebSocket con Socket.io  
✅ **Tipo seguro:** TypeScript en todo el stack  
✅ **Bajo costo inicial:** Docker + ECS (vs. Kubernetes)  
✅ **Privacidad garantizada:** Encriptación end-to-end  
✅ **DevEx excelente:** Comunidad grande, librerías maduras  

---

## 🎯 Criterios de Decisión

### Criterios Técnicos

| Criterio | Peso | Justificación |
|----------|------|---------------|
| **Escalabilidad Horizontal** | ⭐⭐⭐⭐⭐ | MVP puede crecer rápidamente |
| **Latencia de Real-time** | ⭐⭐⭐⭐⭐ | Chat debe ser < 1s |
| **Type Safety** | ⭐⭐⭐⭐ | Errores reducidos en producción |
| **Tiempo de Desarrollo** | ⭐⭐⭐⭐ | Debe lanzarse rápido |
| **Costo Operacional** | ⭐⭐⭐⭐ | MVP tiene presupuesto limitado |
| **Comunidad & Recursos** | ⭐⭐⭐ | Fácil reclutar developers |

### Criterios de Negocio

| Criterio | Peso | Justificación |
|----------|------|---------------|
| **Time-to-market** | ⭐⭐⭐⭐⭐ | Competencia agresiva |
| **Confiabilidad (Uptime)** | ⭐⭐⭐⭐⭐ | Afecta reputación |
| **Privacidad de Usuario** | ⭐⭐⭐⭐⭐ | Requisito regulatorio |
| **Facilidad de Maintenance** | ⭐⭐⭐⭐ | Equipo pequeño inicialmente |
| **Costo de Infra** | ⭐⭐⭐⭐ | Startup lean |

---

## 🏛️ Decisiones Principales

### 1️⃣ Decisión: Frontend Móvil

#### Opción A: React Native ✅ SELECCIONADO
#### Opción B: Flutter
#### Opción C: Desarrollo Nativo (iOS + Android)

| Aspecto | React Native | Flutter | Nativo |
|---------|--------------|---------|--------|
| **Time-to-market** | 🟢 Muy rápido | 🟢 Muy rápido | 🔴 Lento (2x) |
| **Costo Desarrollo** | 🟢 Bajo (1 team) | 🟢 Bajo (1 team) | 🔴 Alto (2 teams) |
| **Performance** | 🟡 Bueno | 🟢 Excelente | 🟢 Excelente |
| **Comunidad** | 🟢 Enorme | 🟡 En crecimiento | 🟢 Grande |
| **Libreríasmaduras** | 🟢 Muy buenas | 🟡 Creciendo | 🟢 Excelentes |
| **Mantenimiento** | 🟢 Un codebase | 🟢 Un codebase | 🔴 Dos codebases |

**Justificación:** React Native permite MVP rápido con un solo equipo de desarrollo. La comunidad es masiva, hay muchas librerías disponibles, y la performance es suficiente para este caso de uso.

---

### 2️⃣ Decisión: Framework Backend

#### Opción A: Node.js + Express ✅ SELECCIONADO
#### Opción B: Django (Python)
#### Opción C: Java Spring Boot
#### Opción D: Go (Gin)

| Aspecto | Express | Django | Spring | Go |
|---------|---------|--------|--------|-----|
| **Real-time** | 🟢 Socket.io nativo | 🟡 Django Channels | 🟡 WebFlux | 🟢 Goroutines |
| **Type Safety** | 🟢 TypeScript | 🟡 Type hints | 🟢 Fuerte | 🟢 Fuerte |
| **Dev Speed** | 🟢 Rápido | 🟢 Rápido | 🟡 Medio | 🟡 Medio |
| **Comunidad** | 🟢 Enorme | 🟢 Enorme | 🟢 Enorme | 🟡 Creciendo |
| **Deployment** | 🟢 Simple | 🟡 Más complejo | 🟡 Heavier | 🟢 Simple |
| **Curva Learning** | 🟢 Suave | 🟢 Suave | 🔴 Empinada | 🟡 Media |

**Justificación:** Express + Node.js es la opción más rápida para MVP. Socket.io está maduro y es fácil de usar. TypeScript agrega seguridad de tipos sin complejidad. El deployment en Docker es trivial.

---

### 3️⃣ Decisión: Base de Datos

#### Opción A: PostgreSQL ✅ SELECCIONADO
#### Opción B: MongoDB
#### Opción C: Firebase Realtime Database

| Aspecto | PostgreSQL | MongoDB | Firebase |
|---------|------------|---------|----------|
| **Relaciones** | 🟢 Excelente | 🔴 Débil | 🔴 Inexistente |
| **Transacciones** | 🟢 ACID completo | 🟡 Limitadas | 🔴 No ACID |
| **Escalabilidad** | 🟢 Vertical + Horizontal | 🟢 Horizontal | 🟢 Automática |
| **Costo** | 🟢 Bajo (Open-source) | 🟢 Bajo (Open-source) | 🔴 Pago por uso |
| **Control** | 🟢 Total | 🟢 Total | 🔴 Vendor lock-in |
| **Queries** | 🟢 SQL Poderoso | 🟡 JavaScript | 🟡 API limitada |

**Justificación:** PostgreSQL es ideal porque nuestro modelo tiene relaciones complejas (usuarios → propiedades → swipes → matches → chat). El ACID es crítico para matches definitivos. JSONB permite flexibilidad para amenities y extra_areas.

---

### 4️⃣ Decisión: Cache

#### Opción A: Redis ✅ SELECCIONADO
#### Opción B: Memcached
#### Opción C: Application Memory

| Aspecto | Redis | Memcached | Memory |
|---------|-------|-----------|--------|
| **Speed** | 🟢 Ultra-rápido | 🟢 Rápido | 🟢 Instantáneo |
| **Data Structures** | 🟢 Ricas | 🟡 Básicas | 🟢 Cualquiera |
| **Persistencia** | 🟢 Sí | 🔴 No | 🔴 No |
| **Cluster** | 🟢 Sí | 🟡 No | 🔴 No |
| **TTL** | 🟢 Nativo | 🟢 Sí | 🟡 Manual |
| **Sessions** | 🟢 Perfecto | 🟡 Funciona | 🔴 No recomendado |

**Justificación:** Redis es perfecto para caché de stacks de swipe (lista de propiedades no-swiped), sesiones JWT, rate limiting, y pub/sub para notificaciones. Las estructuras de datos ricas nos permiten eficiencia en operaciones comunes.

---

### 5️⃣ Decisión: Real-time Communication

#### Opción A: Socket.io ✅ SELECCIONADO
#### Opción B: WebSocket Puro (ws)
#### Opción C: Server-Sent Events (SSE)
#### Opción D: Polling

| Aspecto | Socket.io | WebSocket | SSE | Polling |
|---------|-----------|-----------|-----|---------|
| **Latencia** | 🟢 <100ms | 🟢 <100ms | 🟡 Variabl | 🔴 Segundos |
| **Fallback** | 🟢 Automático | 🔴 No | 🟢 HTTP | 🟢 HTTP |
| **Bandwidth** | 🟢 Óptimo | 🟢 Óptimo | 🟡 Más | 🔴 Mucho |
| **Setup** | 🟢 Simple | 🟡 Medio | 🟡 Medio | 🟢 Simple |
| **Browser Support** | 🟢 Universal | 🟢 Universal | 🟡 No IE | 🟢 Universal |
| **Escalabilidad** | 🟢 Muy buena | 🟡 Requiere setup | 🟡 Media | 🔴 Pobre |

**Justificación:** Socket.io tiene el mejor balance entre funcionalidad, fallback y facilidad de uso. El fallback automático es crítico para usuarios en conexiones malas. La escalabilidad horizontal funciona bien con Redis adapter.

---

### 6️⃣ Decisión: Encriptación de Documentos

#### Opción A: TweetNaCl.js (End-to-End) ✅ SELECCIONADO
#### Opción B: AWS KMS (Server-side)
#### Opción C: OpenSSL
#### Opción D: Sin encriptación (Solo TLS)

| Aspecto | TweetNaCl | AWS KMS | OpenSSL | TLS Solo |
|---------|-----------|---------|---------|----------|
| **Seguridad** | 🟢 Muy fuerte | 🟢 Muy fuerte | 🟢 Fuerte | 🟡 Media |
| **User Privacy** | 🟢 Total | 🟡 Confiamos AWS | 🟡 Confiamos app | 🔴 Confiamos app |
| **Performance** | 🟢 Rápido | 🟡 Latencia AWS | 🟢 Rápido | 🟢 N/A |
| **Complejidad** | 🟢 Simple | 🟡 Requiere setup | 🟡 Media | 🟢 Ninguna |
| **Costo** | 🟢 Gratis | 🟡 $1/10K requests | 🟢 Gratis | 🟢 Gratis |
| **User Control** | 🟢 Total | 🔴 AWS maneja keys | 🟡 App maneja | 🔴 Ninguno |

**Justificación:** TweetNaCl.js + end-to-end permite que usuarios mantengan control de sus claves. Documentos se encriptan en frontend antes de enviar a S3. Combina privacidad con simplicidad.

---

### 7️⃣ Decisión: Deployment

#### Opción A: Docker + ECS (AWS) ✅ SELECCIONADO
#### Opción B: Heroku
#### Opción C: Kubernetes (EKS)
#### Opción D: VM tradicional (EC2)

| Aspecto | ECS | Heroku | Kubernetes | EC2 |
|---------|-----|--------|------------|-----|
| **Setup Time** | 🟢 1-2 horas | 🟢 5 minutos | 🔴 1-2 días | 🟡 Varias horas |
| **Scaling** | 🟢 Automático | 🟢 Automático | 🟢 Automático | 🔴 Manual |
| **Costo** | 🟢 Muy bajo | 🟡 Moderado | 🟡 Moderado | 🟡 Variable |
| **Learning Curve** | 🟡 Media | 🟢 Suave | 🔴 Empinada | 🟢 Suave |
| **Vendor Lock-in** | 🟡 AWS | 🔴 Alto | 🟢 Bajo | 🟢 Bajo |
| **Para MVP** | 🟢 Ideal | 🟢 Bueno | 🔴 Overkill | 🟡 Básico |

**Justificación:** ECS con Docker es el sweet spot para MVP. Costo bajo, scaling automático, integración fácil con RDS y ElastiCache. Si necesitamos Kubernetes después, migramos a EKS.

---

## ⚖️ Trade-offs

### Trade-off 1: Type Safety vs. Flexibility

**Decisión:** Usar TypeScript strict mode

```
VENTAJAS:
✅ Errores atrapados en compilación
✅ Mejor autocomplete en IDE
✅ Documentación autodescriptiva
✅ Menos bugs en producción

DESVENTAJAS:
❌ Curva de aprendizaje (inicialmente)
❌ Compilación adicional
❌ Más boilerplate

JUSTIFICACIÓN: Los beneficios superan las desventajas en MVP crítico.
```

### Trade-off 2: Escalabilidad vs. Complejidad

**Decisión:** PostgreSQL single instance + scaling vertical inicialmente

```
MVP (Ahora):
✅ 1 instance PostgreSQL
✅ Replicación read-only si es necesario
✅ Simple de mantener

Futuro (v2.0+):
📈 Scaling: Sharding por city
📈 Read replicas
📈 Multi-region

JUSTIFICACIÓN: 
- MVP no necesita complejidad de Kubernetes
- PostgreSQL puede manejar 100K users con índices buenos
- Migramos a multi-region cuando justifique el cost
```

### Trade-off 3: Documentos Encriptados vs. Auditoría

**Decisión:** Encriptación end-to-end (sacrificamos auditoría completa)

```
VENTAJA: Privacidad máxima
DESVENTAJA: No podemos auditar contenido de docs en servidor

MITIGACIÓN:
✅ Logs auditados de ACCESO (quién vio qué, cuándo)
✅ DBAN en docs sensibles después de 90 días
✅ User puede revocar acceso en cualquier momento
```

---

## 🛡️ Riesgos Mitigados

### Riesgo 1: Data Exposure

**Escenario:** Hacker accede a base de datos
**Mitigación:**
- ✅ Documentos sensibles encriptados (no se pueden leer sin key)
- ✅ Contraseñas salted bcrypt (no se pueden recuperar)
- ✅ TLS en transit
- ✅ Row-Level Security en PostgreSQL
- ✅ Backups encriptados

**Severidad Reducida:** 🔴 CRÍTICA → 🟡 MEDIA

---

### Riesgo 2: DoS Attack

**Escenario:** Attacker hace spam de requests
**Mitigación:**
- ✅ Rate limiting (Redis)
  - 5 login attempts por IP en 15 min
  - 100 swipes por usuario en 1 hora
  - 50 mensajes por usuario en 5 min
- ✅ CAPTCHA en login después de N fallos
- ✅ DDoS protection (CloudFlare/AWS Shield)

**Severidad Reducida:** 🔴 CRÍTICA → 🟢 BAJA

---

### Riesgo 3: Real-time Chat Failure

**Escenario:** WebSocket se cae durante conversación
**Mitigación:**
- ✅ Fallback a polling (Socket.io automático)
- ✅ Mensajes persistidos en DB
- ✅ Reconexión automática
- ✅ Notificaciones de mensajes no entregados

**Severidad Reducida:** 🟡 ALTA → 🟢 BAJA

---

### Riesgo 4: Match Consistency

**Escenario:** Race condition entre tenant like y owner match
**Mitigación:**
- ✅ Transacciones ACID en PostgreSQL
- ✅ Unique constraint en matches (tenant, property)
- ✅ Idempotent endpoints
- ✅ Optimistic locking si es necesario

**Severidad Reducida:** 🟡 ALTA → 🟢 BAJA

---

### Riesgo 5: Uncontrolled Scaling Costs

**Escenario:** Tráfico inesperado causa factura de AWS gigante
**Mitigación:**
- ✅ CloudWatch alarms automáticas
- ✅ Budget alerts en AWS
- ✅ Auto-scaling con límites máximos
- ✅ Rate limiting por tenant
- ✅ Reserved instances para baseline

**Severidad Reducida:** 🟡 MEDIA → 🟢 BAJA

---

## 📊 Matriz de Decisiones

```
DECISIÓN                  RIESGO    REVERSIBILIDAD    COSTO CAMBIO
────────────────────────────────────────────────────────────────
Frontend: React Native    🟢 Bajo   🟡 Difícil        Alto
Backend: Express          🟢 Bajo   🟢 Fácil          Bajo
DB: PostgreSQL            🟡 Medio  🔴 Muy difícil    Muy Alto
Cache: Redis              🟢 Bajo   🟢 Fácil          Bajo
Real-time: Socket.io      🟢 Bajo   🟢 Fácil          Bajo
Encryption: TweetNaCl     🟢 Bajo   🟡 Difícil        Medio
Deploy: ECS               🟢 Bajo   🟢 Fácil          Bajo
```

---

## ✅ Checklist de Validación Arquitectónica

- [x] Diseño escalable horizontalmente
- [x] Real-time latency < 1 segundo
- [x] Privacidad de datos garantizada
- [x] Type safety en todo el stack
- [x] Costo operacional bajo (<$500/mes MVP)
- [x] Time-to-market < 2 meses
- [x] 99.5% uptime achievable
- [x] Fácil para nuevos developers
- [x] Monitorable y debuggeable
- [x] GDPR compliant
- [x] Escalable a 100K users sin refactor mayor

---

## 🎓 Lecciones Aprendidas (Post-MVP)

### Si Escalamos a v2.0

**Posible Evolución:**
```
ACTUAL (MVP):
├─ 1 app instance
├─ 1 PostgreSQL instance
├─ 1 Redis instance
└─ ~50K max users

FUTURO (v2.0):
├─ 3-5 app instances (load balanced)
├─ PostgreSQL (1 primary + 2 read replicas)
├─ Redis Cluster (3 nodes)
├─ S3 + CloudFront
├─ ElastiCache (managed)
├─ RDS (managed)
└─ ~1M users
```

---

## 📚 Documentos Relacionados

- `database.sql` - Implementación PostgreSQL
- `ARQUITECTURA_Y_API.md` - Especificación completa
- `BACKEND_SETUP.md` - Guía de desarrollo
- `IMPLEMENTACION_Y_DEPLOYMENT.md` - Guía de operaciones

---

## 🔗 Referencias

- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [The Twelve-Factor App](https://12factor.net/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Socket.io Documentation](https://socket.io/docs/)
- [AWS Well-Architected Framework](https://aws.amazon.com/es/architecture/well-architected/)

---

**Revisado y Aprobado Por:**

- [ ] Arquitecto de Soluciones
- [ ] Lead Backend
- [ ] Lead Mobile
- [ ] CTO

---

**Última actualización:** 24 de Junio de 2026  
**Versión:** 1.0.0  
**Confidencialidad:** Interna

