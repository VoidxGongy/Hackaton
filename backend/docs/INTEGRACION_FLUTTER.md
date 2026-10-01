# Integración Flutter con el backend de Supervisión Inteligente

Este documento describe cómo debe consumir el backend desde Flutter. La información y las reglas de negocio provienen directamente del código actual del backend (`src/`).

## 1. Configuración base
- **Base URL:** `http://<host-backend>:3000` en local: `http://localhost:3000` (o la IP/host del backend en producción).
- **Sin prefijo** `/api`; todas las rutas están en la raíz.
- **Login de supervisores demo (seed):**
  - Coordinador: `coordinador@empresa.com` / `password123`
  - Supervisor: `supervisor@empresa.com` / `password123`

## 2. Dependencias en Flutter
- HTTP: paquete `http` (o `dio`).
- Preferencias locales: `shared_preferences`.
- Conectividad: `connectivity_plus`.
- Cola offline: `hive`/`drift`/`isar` (almacenamiento local) + worker (ej. `workmanager` o `background_fetch`) para reenviar pendientes.
- (Opcional) FCM: `firebase_messaging` para registrar el `push_token`.

## 3. Flujo de login
1. Enviar `POST /auth/login` con `{ email, password }`.
2. Guardar en `SharedPreferences` (encriptado preferible, p. ej. `flutter_secure_storage`):
   - `accessToken` (JWT, 15 min).
   - `refreshToken` (JWT, 7 días).
   - `usuario`: `{ id, email, nombre, rol, supervisorId?, coordinadorId? }`.
3. Enviar `Authorization: Bearer <accessToken>` en cada request.
4. **Expiración:** cuando una llamada devuelva `401` con el access token, intentar `POST /auth/refresh` con `{ refreshToken }`; si devuelve 201, reemplazar `accessToken` y reenviar la request fallida. Si `/auth/refresh` falla (401), cerrar sesión (limpiar tokens) y volver al login.

## 4. Almacenamiento y envío del JWT
- El `accessToken` se envía en el header `Authorization: Bearer <accessToken>`.
- Si el access token expiró, usa `refreshToken` (vía `/auth/refresh`) antes de reenviar. Nunca guardes ni loguees el `refreshToken` ni `accessToken`.

## 5. Flujo Coordinador
- Login → coordinador. Rutas disponibles:
  - `POST /coordinador/supervisores` — crear supervisor (email, password, nombre, …).
  - `GET /coordinador/supervisores` y `/coordinador/supervisores/:id` — listar/ver.
  - `POST /coordinador/areas/:areaId/supervisores/:supervisorId` — asignar supervisor a área.
  - `POST /coordinador/visitas` — crear/asignar visita (supervisorId, areaId, titulo, prioridad, fechaProgramada, clienteId opcional).
  - `GET /coordinador/visitas/pendientes|completadas|historial`.
- Un coordinador NO puede acceder a `/visitas` (rol SUPERVISOR).

## 6. Flujo Supervisor
- Login → supervisor. Las rutas que le importan:
  - `GET /visitas` (opcional `?estado=`) — mis visitas pendientes/en curso/ completadas.
  - `GET /visitas/:id` — detalle (área, fecha/hora programada, prioridad, tareas, novedades, evidencias).
  - `POST /visitas/:id/llegada` y `/visitas/:id/salida` — registrar horas (body opcional `{ hora }`; si no se envía, el servidor usa la hora actual).
  - `POST /tareas/visita/:visitaId` y `PATCH /tareas/:id` — crear y marcar tareas (CUMPLIDA / NO_CUMPLIDA / PENDIENTE).
  - `POST /novedades/visita/:visitaId`, `GET /novedades` — registrar/listar novedades.
  - `POST /evidencias`, `GET /evidencias/visita/:visitaId` — registrar fotos; la evidencia puede asociarse a novedad/tarea/visita.
  - `POST /checkin/:visitaId` — check-in con QR.
  - `POST /sync` — sincronizar operaciones offline.
  - `POST /dispositivos` — registrar el `push_token` del device para FCM.

## 7. Flujo de visita
- El supervisor consulta `GET /visitas` → obtiene la lista con `area`, `prioridad`, `fechaProgramada`, `tareas`, `novedades`, `evidencias`.
- Abre el detalle `GET /visitas/:id` para ver tareas, prioridad y programa.
- Para iniciar: check-in con QR (`POST /checkin/:visitaId`). El backend pasa el estado a `EN_CURSO` y setea `horaLlegada`.
- Ejecuta tareas (`PATCH /tareas/:id` con estado `CUMPLIDA`/`NO_CUMPLIDA`) y registra observaciones/novedades.
- Para finalizar: `POST /visitas/:id/salida` → estado `COMPLETADA`, `horaSalida`.

## 8. Flujo QR / check-in
1. El área tiene un `qr_token` UUID (se obtiene con `GET /areas/:id` o `GET /areas`).
2. El supervisor escanea el QR físico del área (Flutter lee el UUID).
3. Flutter envía `POST /checkin/:visitaId` con `{ qr_token }`.
4. El backend:
   - Verifica que la visita le pertenezca al supervisor auth (sino `400`).
   - Busca el área por `qr_token` (`GET` implícito del área).
   - Comprueba que el área del QR coincida con el área de la visita (sino `409`).
   - Confirma el check-in en BD (`estado=EN_CURSO`, `horaLlegada=ahora`) dentro de una transacción, y registra un `SyncOperacion` (`CHECK_IN`, `COMPLETED`).
   - Luego, **fuera** de la transacción, envía notificación FCM al coordinador. Si FCM falla o no está configurado, el check-in **NO** se revierte.
5. Si el supervisor escaneó sin conexión, la operación se guarda localmente y se envía al backend mediante el lote de sincronización (`POST /sync`); el backend valida el QR allí.

## 9. Check-out
- `POST /visitas/:id/salida` con body opcional `{ hora }`.
- El backend pone `estado=COMPLETADA` y setea `horaSalida` (o la hora del servidor si no se envía).

## 10. Tareas
- Crear (online directo o offline vía sync): `POST /tareas/visita/:visitaId` con `descripcion`, `prioridad`, `orden`, `uuid_local`.
- Marcar: `PATCH /tareas/:id` con `{ "estado": "CUMPLIDA" | "NO_CUMPLIDA" | "PENDIENTE" }`.

## 11. Novedades
- Registrar: `POST /novedades/visita/:visitaId` con `titulo`, `descripcion`, `tipo`, `prioridad`, `uuid_local`.
- El coordinador consulta `GET /novedades/coord`, cambia estado con `PATCH /novedades/:id/estado`.

## 12. Evidencias
- Subir: `POST /evidencias` con `uri`, `tipo` (`FOTOGRAFICA|VIDEO|FIRMA|DOCUMENTO`), `descripcion`, y asociar a `novedadId` o `tareaId` o `visitaId`.
- El backend valida que la evidencia pertenezca a una visita del supervisor auth (protección de acceso).
- Listar: `GET /evidencias/visita/:visitaId`.
- **Nota sobre `uri`:** el backend almacena la cadena que Flutter envíe (URL/path local). Si Flutter sube a un storage y envía la URL, el backend la guarda; si aún no hay conectividad, Flutter guarda la ruta local y envía la operación a `/sync` con `uuid_local`.

## 13. Sincronización offline
Reglas del protocolo backend (`/sync`):
- Flutter envía el lote en `{ "operaciones": [ { "uuid_local", "entidad", "accion", "datos" } ] }`.
- `entidad` ∈ `Visita | TareaRevision | Novedad | Evidencia | Dispositivo`.
- `accion` ∈ `CREAR | ACTUALIZAR | ELIMINAR | CHECK_IN`.
- `datos` es un objeto JSON con los campos de la entidad (el backend también acepta el JSON como string).
- Cada operación del lote se procesa **individualmente** (no hay una transacción gigante por todo el lote).
- **Idempotencia y trazabilidad:** se crea/actualiza un registro `SyncOperacion` con `uuid_local`, `entidad`, `accion`, `estado` y `intentos`. Si una operación con el mismo `uuid_local` + `entidad` ya fue procesada (`APPLIED`/`COMPLETED`/`DUPLICATE`), se devuelve `estado=DUPLICATE` sin reprocesar.
- Estados posibles en la respuesta: `APPLIED`, `DUPLICATE`, `REJECTED`, `CONFLICT`, `RETRY`, `COMPLETED`, `PENDIENTE`.
- Flutter debe conservar localmente el `uuid_local` de cada operación offline y reenviarla; el backend evita duplicados gracias al unique `(uuid_local, entidad)`.

## 14. Idempotencia
- Usa siempre `uuid_local` generado por Flutter en dispositivos offline.
- Reenviar el mismo `uuid_local` + `entidad` devolverá `DUPLICATE` con el `resultadoId` previo (el id del servidor asignado en la primera aplicación).
- Para reintentos fallidos, Flutter puede reenviar; el backend marcará `RETRY` e intentará aplicarla.

## 15. Manejo de errores HTTP ( Flutter debe interpretar )
- `401` → token inválido/expirado. Refrescar o redirigir al login.
- `403` → el usuario está logueado pero su rol no permite la operación. No reintentar; corregir permisos.
- `400` → datos inválidos de negocio (p. ej. visita que no te pertenece) o fecha en el pasado.
- `404` → recurso inexistente.
- `409` → conflicto de negocio (QR de otro área, visita ya iniciada/completada). Resolver en UI.
- `422` → validación de DTO (campos faltantes, tipo/ formato incorrecto, campos no permitidos). Mostrar al usuario.
- `429` → rate limit (300 req/min por IP). Reintentar con back-off.
- `500` → error de servidor. Reintentar.

## 16. Qué datos conservar localmente para trabajar offline
- Catálogo base descargado bajo demanda: áreas (con `qr_token`), supervisores (solo las propias) y visitas asignadas.
- Para cada visita: tareas, prioridad, fecha/hora programada, área.
- Operaciones creadas offline con su `uuid_local`: tareas, novedades, evidencias (path local + metadata), registros de check-in y horas (llegada/salida) con `uuid_local`.
- El `push_token` del device y la plataforma.
- `accessToken` y `refreshToken` en almacenamiento seguro (`flutter_secure_storage`); refrescar cuando expire el access.

## 17. Qué operaciones pueden quedar pendientes de sincronización
- Creación/actualización de tareas.
- Creación de novedades.
- Creación de evidencias (con `uri` local + `uuid_local`).
- Check-in mediante QR (accion `CHECK_IN` sobre `Visita`).
- Registro de llegada/salida (via sync sobre `Visita`).
- Registro/actualización de dispositivo (push_token).

## 18. Comportamiento cuando FCM no está configurado
- Si la variable de entorno `FCM_JSON_KEY` no está definida, el backend arranca sin inicializar Firebase y salta un *warning* en logs.
- El envío de notificaciones push se omite **graciosamente** (no crashea, no revierte operaciones).
- El check-in del supervisor sigue funcionando normalmente; simplemente no se envía la notificación al coordinador.
- Las notificaciones FCM al coordinador (por check-in) solo se enviarán cuando `FCM_JSON_KEY` esté configurada como JSON de service-account.

## 19. Arranque y entornos
- **Swagger UI:** `http://localhost:3000/docs`
- **OpenAPI JSON:** `http://localhost:3000/docs-json`
- **Arrancar backend:** `npm start` (requiere `npm run build` previamente) o `node dist/main`.
- **Levantar PostgreSQL:** `docker compose up -d db` (o `docker compose up -d` para levantar DB + backend).
- **Variables de entorno necesarias** (sin secretos): `PORT`, `DATABASE_URL`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, `JWT_ACCESS_EXPIRES_IN`, `JWT_REFRESH_EXPIRES_IN`, `BCRYPT_SALT_ROUNDS`, `FCM_JSON_KEY` (opcional), `RATE_LIMIT_WINDOW_MS`, `RATE_LIMIT_MAX`. Se usan los archivos `.env` (local) y `.env.docker` (compose).
