# API REST — Documentación para frontend Flutter

Base URL de la API: `http://<host>:3000` (en local: `http://localhost:3000`).

La API NO usa prefijo `/api`; todas las rutas están en la raíz.

Todas las rutas, salvo las de autenticación marcadas como públicas, exigen:
- Header `Authorization: Bearer <access_token>` (JWT de acceso, 15 min).
- Los roles se validan con un guard global de roles.

Códigos de error HTTP habituales:
- `401 Unauthorized` — sin token o token inválido/expirado.
- `403 Forbidden` — autenticado pero sin el rol necesario.
- `404 Not Found` — recurso inexistente.
- `409 Conflict` — conflicto de negocio (p. ej. QR de otro área, visita ya iniciada).
- `422 Unprocessable Entity` — validación de DTO (datos inválidos o campos no permitidos).

---

## Autenticación

### Login
- **Método:** `POST`
- **Ruta:** `/auth/login`
- **Rol requerido:** Ninguno (ruta pública `@Public`)
- **Requiere JWT:** No
- **Headers:** `Content-Type: application/json`
- **Body:**
```json
{
  "email": "coordinador@empresa.com",
  "password": "password123"
}
```
- **Respuesta 201:**
```json
{
  "accessToken": "<jwt-access-15m>",
  "refreshToken": "<jwt-refresh-7d>",
  "usuario": {
    "id": "uuid",
    "email": "coordinador@empresa.com",
    "nombre": "Coordinador Demo",
    "rol": "COORDINADOR"
  }
}
```
- **Errores:** `401` credenciales inválidas · `422` email/ password no válidos (password mínimo 6).
- **Ejemplo:**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"coordinador@empresa.com","password":"password123"}'
```

### Refresh token
- **Método:** `POST`
- **Ruta:** `/auth/refresh`
- **Rol:** COORDINADOR o SUPERVISOR
- **Requiere JWT:** Access token válido (`Authorization: Bearer <accessToken>`)
- **Headers:** `Content-Type: application/json` + `Authorization: Bearer <accessToken>`
- **Body:**
```json
{ " refreshToken": "<jwt-refresh>" }
```
- **Respuesta 201:** `{ "accessToken": "<nuevo-jwt-access-15m>" }`
- **Errores:** `401` refresh token inválido.

### Logout
- **Método:** `POST`
- **Ruta:** `/auth/logout`
- **Rol:** COORDINADOR o SUPERVISOR
- **Requiere JWT:** Sí
- **Body:** `{ "refreshToken": "<jwt-refresh>" }`
- **Respuesta 201:** `{ "ok": true }`
- **Nota:** por simplicidad del hackathon la revocación se realiza del lado del cliente (borrando el token); el refresh no es revocado en servidor.

### Perfil (me)
- **Método:** `GET`
- **Ruta:** `/auth/me`
- **Rol:** COORDINADOR o SUPERVISOR
- **Requiere JWT:** Sí
- **Respuesta 200:**
```json
{
  "sub": "uuid-usuario",
  "email": "coordinador@empresa.com",
  "nombre": "Coordinador Demo",
  "rol": "COORDINADOR",
  "supervisorId": "uuid-supervisor",
  "coordinadorId": "uuid-coordinador"
}
```
(`supervisorId`/`coordinadorId` aparecen según el rol del usuario.)

---

## Coordinador

> Todas las rutas requieren JWT y rol `COORDINADOR`.

### Crear supervisor
- **Método:** `POST`
- **Ruta:** `/coordinador/supervisores`
- **Body:**
```json
{
  "email": "supervisor2@empresa.com",
  "password": "password123",
  "nombre": "Ana Gómez",
  "numeroIdentificacion": "123456789",
  "telefono": "3001234567"
}
```
- **Respuesta 201:** (sin `password`)
```json
{
  "id": "uuid-usuario",
  "email": "supervisor2@empresa.com",
  "nombre": "Ana Gómez",
  "rol": "SUPERVISOR",
  "activo": true,
  "supervisor": { "id": "uuid-supervisor", "numeroIdentificacion": "...", "telefono": "..." }
}
```
- **Errores:** `400` email ya registrado · `422`.

### Listar supervisores
- **Método:** `GET`
- **Ruta:** `/coordinador/supervisores`
- **Respuesta 200:** arreglo de:
```json
[
  {
    "id": "uuid-supervisor",
    "supervisorId": "..." ,
    "areaId": "...",
    "createdAt": "...",
    "usuario": { "id": "...", "email": "...", "nombre": "...", "rol": "SUPERVISOR", "activo": true },
    "supervisorAreas": [ { "id": "...", "supervisorId": "...", "areaId": "...", "createdAt": "..." } ]
  }
]
```

### Ver supervisor
- **Método:** `GET`
- **Ruta:** `/coordinador/supervisores/:id`
- **Respuesta 200:** mismo shape que el arreglo, un solo objeto. `404` si no existe.

### Asignar supervisor a área
- **Método:** `POST`
- **Ruta:** `/coordinador/areas/:areaId/supervisores/:supervisorId`
- **Body:** vacío `{}`
- **Respuesta 201:**
```json
{ "id": "uuid-supervisorArea", "supervisorId": "...", "areaId": "...", "createdAt": "..." }
```

### Asignar (crear) visita
- **Método:** `POST`
- **Ruta:** `/coordinador/visitas`
- **Body:**
```json
{
  "supervisorId": "uuid",
  "areaId": "uuid",
  "titulo": "Inspección edificio sur",
  "descripcion": "Revisión de servicios de aseo",
  "prioridad": "ALTA",
  "fechaProgramada": "2026-10-10T09:00:00.000Z",
  "clienteId": "uuid"
}
```
`prioridad` ∈ `BAJA | MEDIA | ALTA`. `descripcion`, `clienteId` opcionales.
- **Respuesta 201:** objeto `Visita`:
```json
{
  "id": "uuid-visita",
  "supervisorId": "...",
  "areaId": "...",
  "clienteId": "...",
  "titulo": "...",
  "descripcion": "...",
  "prioridad": "ALTA",
  "estado": "PROGRAMADA",
  "fechaProgramada": "2026-10-10T09:00:00.000Z",
  "horaLlegada": null,
  "horaSalida": null,
  "uuid_local": null,
  "createdAt": "...",
  "updatedAt": "...",
  "area": { "id": "...", "nombre": "...", "qr_token": "..." },
  "supervisor": { "id": "...", "usuario": {...} }
}
```
- **Errores:** `404` supervisor/área no encontrados · `400` fecha en el pasado.

### Visitas pendientes
- **Método:** `GET`
- **Ruta:** `/coordinador/visitas/pendientes`
- **Respuesta 200:** arreglo de visitas con `area` y `supervisor`.

### Visitas completadas
- **Método:** `GET`
- **Ruta:** `/coordinador/visitas/completadas`
- **Respuesta 200:** arreglo de visitas.

### Historial de visitas
- **Método:** `GET`
- **Ruta:** `/coordinador/visitas/historial`
- **Respuesta 200:** arreglo de visitas `COMPLETADA` y `EN_CURSO`, incluye `novedades` y `evidencias`.

---

## Supervisor

> La lista completa de supervisores está en `/coordinador/supervisores` (CRUD solo para coordinador). Los supervisores consultan sus propias visitas desde `/visitas`.

---

## Áreas

### Listar áreas
- **Método:** `GET`
- **Ruta:** `/areas`
- **Rol:** COORDINADOR o SUPERVISOR · **JWT:** Sí
- **Respuesta 200:** arreglo:
```json
[
  {
    "id": "uuid",
    "nombre": "Edificio Central",
    "descripcion": "...",
    "direccion": "...",
    "qr_token": "uuid",
    "clientId": null,
    "createdAt": "...", "updatedAt": "...",
    "clientes": [ { "id": "...", "cliente": {...} } ]
  }
]
```

### Ver área
- **Método:** `GET`
- **Ruta:** `/areas/:id`
- **Respuesta 200:** un área con `qr_token` (el token que escanea Flutter). `404` si no existe.

### Crear área
- **Método:** `POST`
- **Ruta:** `/areas`
- **Rol:** COORDINADOR · **JWT:** Sí
- **Body:**
```json
{ "nombre": "Edificio Sur", "descripcion": "...", "direccion": "...", "clienteId": "uuid" }
```
- **Respuesta 201:** área creada (incluye `qr_token`).

---

## Visitas

> Todas las rutas requieren rol `SUPERVISOR` y solo devuelven las visitas del supervisor autenticado.

### Listar mis visitas
- **Método:** `GET`
- **Ruta:** `/visitas`
- **Query opcional:** `?estado=PROGRAMADA|EN_CURSO|COMPLETADA|CANCELADA`
- **Respuesta 200:** arreglo de visitas con `area`, `tareas`, `novedades`, `evidencias`.

### Ver visita
- **Método:** `GET`
- **Ruta:** `/visitas/:id`
- **Respuesta 200:** visita con `area`, `tareas`, `novedades`, `evidencias`. `404` si no existe; `400` si no es tuya.

### Registrar llegada (check-out manual / sin QR)
- **Método:** `POST`
- **Ruta:** `/visitas/:id/llegada`
- **Body:** `{ "hora": "2026-10-10T09:05:00.000Z" }` (`hora` opcional; si no se envía usa la hora del servidor).
- **Respuesta 201:** visita actualizada (`estado` pasa a `EN_CURSO`, `horaLlegada` set).

### Registrar salida (check-out)
- **Método:** `POST`
- **Ruta:** `/visitas/:id/salida`
- **Body:** `{ "hora": "..." }` (opcional).
- **Respuesta 201:** visita actualizada (`estado` → `COMPLETADA`, `horaSalida` set).

---

## Tareas de revisión

> Rol `SUPERVISOR`. Las tareas pertenecen a una visita del supervisor auth.

### Crear tarea (offline vía sync también)
- **Método:** `POST`
- **Ruta:** `/tareas/visita/:visitaId`
- **Body:**
```json
{
  "descripcion": "Verificar extintor",
  "prioridad": "ALTA",
  "orden": 1,
  "uuid_local": "<uuid-local-flutter>"
}
```
- **Respuesta 201:** `TareaRevision`:
```json
{ "id": "uuid", "visitaId": "...", "descripcion": "...", "prioridad": "ALTA", "estado": "PENDIENTE", "orden": 1, "uuid_local": null, "createdAt": "...", "updatedAt": "..." }
```

### Cambiar estado de tarea
- **Método:** `PATCH`
- **Ruta:** `/tareas/:id`
- **Body:** `{ "estado": "CUMPLIDA | NO_CUMPLIDA | PENDIENTE" }`
- **Respuesta 200:** `TareaRevision` actualizada.

---

## Check-in / Check-out (QR)

> Rol `SUPERVISOR`. El supervisor escanea el `qr_token` del área física y el backend lo valida contra la visita.

### Check-in mediante QR
- **Método:** `POST`
- **Ruta:** `/checkin/:visitaId`
- **Body:**
```json
{ "qr_token": "<uuid-escaneado-del-área>" }
```
- **Respuesta 201:**
```json
{
  "ok": true,
  "visitaId": "...",
  "areaId": "...",
  "areaNombre": "Edificio Central",
  "horaLlegada": "2026-10-01T18:52:06.768Z",
  "estado": "EN_CURSO"
}
```
- **Validaciones / errores:**
  - `400` si la visita no es del supervisor autenticado.
  - `409` si el `qr_token` corresponde a otro área que no la de la visita.
  - `409` si la visita ya está `COMPLETADA`/`CANCELADA`.
- **Efectos secundarios:** el check-in se confirma en BD (se crea un registro `SyncOperacion` con `accion=CHECK_IN`, `estado=COMPLETED`) y se intenta notificar al coordinador vía FCM. Si FCM no está configurado o falla, el check-in **NO** se revierte.

---

## Novedades

### Crear novedad
- **Método:** `POST`
- **Ruta:** `/novedades/visita/:visitaId`
- **Rol:** SUPERVISOR · **JWT:** Sí
- **Body:**
```json
{
  "titulo": "Fuga de agua crítica",
  "descripcion": "Tubería rota en baño",
  "tipo": "GENERAL|CRITICA|SUGERENCIA|INCUMPLIMIENTO|OTRO",
  "prioridad": "BAJA|MEDIA|ALTA",
  "uuid_local": "<uuid-local-flutter>"
}
```
- **Respuesta 201:** `Novedad`:
```json
{
  "id": "uuid", "visitaId": "...", "titulo": "...", "descripcion": "...",
  "tipo": "CRITICA", "prioridad": "ALTA", "estado": "ABIERTA",
  "uuid_local": null, "createdAt": "...", "updatedAt": "...",
  "evidencias": []
}
```

### Listar mis novedades
- **Método:** `GET`
- **Ruta:** `/novedades`
- **Rol:** SUPERVISOR · **JWT:** Sí
- **Respuesta 200:** arreglo de novedades con `evidencias` y `visita.area`.

### Listar novedades (coordinador)
- **Método:** `GET`
- **Ruta:** `/novedades/coord`
- **Rol:** COORDINADOR · **JWT:** Sí
- **Respuesta 200:** arreglo de todas las novedades con `evidencias`, `visita.area` y `visita.supervisor.usuario`.

### Cambiar estado de novedad
- **Método:** `PATCH`
- **Ruta:** `/novedades/:id/estado`
- **Rol:** COORDINADOR · **JWT:** Sí
- **Body:** `{ "estado": "ABIERTA|EN_REVISION|CERRADA" }`
- **Respuesta 200:** `Novedad` actualizada.

---

## Evidencias

> Rol `SUPERVISOR`. Protegida: una evidencia solo se crea sobre una visita/tarea/novedad que pertenezca al supervisor auth.

### Crear evidencia
- **Método:** `POST`
- **Ruta:** `/evidencias`
- **Body:**
```json
{
  "uri": "https://storage.example/foto1.jpg",
  "tipo": "FOTOGRAFICA|VIDEO|FIRMA|DOCUMENTO",
  "descripcion": "Foto del baño sucio",
  "uuid_local": "<uuid-local-flutter>",
  "novedadId": "uuid",
  "tareaId": "uuid",
  "visitaId": "uuid"
}
```
Debe enviarse `novedadId` o `tareaId` o `visitaId`.
- **Respuesta 201:** `Evidencia`:
```json
{
  "id": "uuid", "uuid_local": null, "visitaId": "...|null", "tareaId": "...|null",
  "novedadId": "...|null", "uri": "...", "tipo": "FOTOGRAFICA",
  "descripcion": "...", "createdAt": "..."
}
```

### Listar evidencias de una visita
- **Método:** `GET`
- **Ruta:** `/evidencias/visita/:visitaId`
- **Rol:** SUPERVISOR · **JWT:** Sí
- **Respuesta 200:** arreglo de `Evidencia`.

---

## Sincronización (offline)

> Rol `SUPERVISOR`. Recibe operaciones creadas offline en Flutter. Cada operación se procesa individualmente (no hay transacción única por lote) y es idempotente.

### Procesar lote
- **Método:** `POST`
- **Ruta:** `/sync`
- **Body:**
```json
{
  "operaciones": [
    {
      "uuid_local": "<uuid-local-flutter>",
      "entidad": "Visita|TareaRevision|Novedad|Evidencia|Dispositivo",
      "accion": "CREAR|ACTUALIZAR|ELIMINAR|CHECK_IN",
      "datos": { "...": "..." }
    }
  ]
}
```
- **Respuesta 201:**
```json
{
  "resultados": [
    {
      "uuid_local": "...",
      "entidad": "TareaRevision",
      "accion": "CREAR",
      "estado": "APPLIED",          // APPLIED | DUPLICATE | REJECTED | CONFLICT | RETRY | COMPLETED
      "resultadoId": "uuid-servidor",
      "mensaje": "..."              // solo en DUPLICATE/REJECTED/CONFLICT
    }
  ]
}
```
- **Idempotencia:** si una operación con el mismo `uuid_local` + `entidad` ya fue procesada (`APPLIED`/`COMPLETED`/`DUPLICATE`), se devuelve `DUPLICATE` sin reprocesar.

---

## Dispositivos

> Registro de device push tokens. Rol `SUPERVISOR` o `COORDINADOR`.

### Registrar dispositivo
- **Método:** `POST`
- **Ruta:** `/dispositivos`
- **Body:**
```json
{ "push_token": "<token-fcm>", "plataforma": "android|ios" }
```
- **Respuesta 201:** `{ "id": "...", "usuarioId": "...", "pushToken": "...", "plataforma": "...", "activo": true, "fechaRegistro": "..." }`

### Desactivar dispositivo
- **Método:** `DELETE`
- **Ruta:** `/dispositivos`
- **Body:** `{ "push_token": "...", "plataforma": "..." }`
- **Respuesta 200:** `{ "count": 1 }`

---

## Evaluación de cliente

> Rol `COORDINADOR`.

### Crear evaluación
- **Método:** `POST`
- **Ruta:** `/evaluaciones`
- **Body:**
```json
{
  "visitaId": "uuid",
  "clienteId": "uuid",
  "puntuacion": 4,          // 0..5, opcional
  "comentario": "Visita cumplida"
}
```
El `coordinadorId` se toma del JWT del usuario auth.
- **Respuesta 201:** `EvaluacionCliente`:
```json
{ "id": "uuid", "visitaId": "...", "clienteId": "...", "coordinadorId": "...", "puntuacion": 4, "comentario": "...", "createdAt": "..." }
```
- **Errores:** `404` visita/cliente/coordinador no encontrados.

### Listar evaluaciones de una visita
- **Método:** `GET`
- **Ruta:** `/evaluaciones/visita/:visitaId`
- **Rol:** COORDINADOR · **JWT:** Sí
- **Respuesta 200:** arreglo con `cliente` y `coordinador`.

---

## Rate limiting
- Límite global: 300 requests por minuto por IP. Superado devuelve `429`.
- Headers informativos: `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`.
