-- CreateEnum
CREATE TYPE "Rol" AS ENUM ('SUPERVISOR', 'COORDINADOR');

-- CreateEnum
CREATE TYPE "TipoNovedad" AS ENUM ('GENERAL', 'CRITICA', 'SUGERENCIA', 'INCUMPLIMIENTO', 'OTRO');

-- CreateEnum
CREATE TYPE "Prioridad" AS ENUM ('BAJA', 'MEDIA', 'ALTA');

-- CreateEnum
CREATE TYPE "PrioridadNovedad" AS ENUM ('BAJA', 'MEDIA', 'ALTA');

-- CreateEnum
CREATE TYPE "EstadoVisita" AS ENUM ('PROGRAMADA', 'EN_CURSO', 'COMPLETADA', 'CANCELADA');

-- CreateEnum
CREATE TYPE "EstadoTarea" AS ENUM ('PENDIENTE', 'CUMPLIDA', 'NO_CUMPLIDA');

-- CreateEnum
CREATE TYPE "EstadoNovedad" AS ENUM ('ABIERTA', 'EN_REVISION', 'CERRADA');

-- CreateEnum
CREATE TYPE "TipoEvidencia" AS ENUM ('FOTOGRAFICA', 'VIDEO', 'FIRMA', 'DOCUMENTO');

-- CreateEnum
CREATE TYPE "AccionSync" AS ENUM ('CREAR', 'ACTUALIZAR', 'ELIMINAR', 'CHECK_IN');

-- CreateEnum
CREATE TYPE "EstadoSync" AS ENUM ('PENDIENTE', 'APPLIED', 'DUPLICATE', 'REJECTED', 'CONFLICT', 'RETRY', 'COMPLETED');

-- CreateTable
CREATE TABLE "usuarios" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "rol" "Rol" NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supervisores" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "numeroIdentificacion" TEXT,
    "telefono" TEXT,

    CONSTRAINT "supervisores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "coordinadores" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "telefono" TEXT,

    CONSTRAINT "coordinadores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "email" TEXT,
    "telefono" TEXT,
    "direccion" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "areas" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "direccion" TEXT,
    "qr_token" TEXT NOT NULL,
    "clientId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cliente_areas" (
    "id" TEXT NOT NULL,
    "clienteId" TEXT NOT NULL,
    "areaId" TEXT NOT NULL,

    CONSTRAINT "cliente_areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supervisor_areas" (
    "id" TEXT NOT NULL,
    "supervisorId" TEXT NOT NULL,
    "areaId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "supervisor_areas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "visitas" (
    "id" TEXT NOT NULL,
    "supervisorId" TEXT NOT NULL,
    "areaId" TEXT NOT NULL,
    "clienteId" TEXT,
    "titulo" TEXT NOT NULL,
    "descripcion" TEXT,
    "prioridad" "Prioridad" NOT NULL DEFAULT 'MEDIA',
    "estado" "EstadoVisita" NOT NULL DEFAULT 'PROGRAMADA',
    "fechaProgramada" TIMESTAMP(3) NOT NULL,
    "horaLlegada" TIMESTAMP(3),
    "horaSalida" TIMESTAMP(3),
    "uuid_local" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "visitas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tareas_revision" (
    "id" TEXT NOT NULL,
    "visitaId" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "prioridad" "Prioridad" NOT NULL DEFAULT 'MEDIA',
    "estado" "EstadoTarea" NOT NULL DEFAULT 'PENDIENTE',
    "orden" INTEGER NOT NULL DEFAULT 0,
    "uuid_local" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tareas_revision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "novedades" (
    "id" TEXT NOT NULL,
    "visitaId" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descripcion" TEXT,
    "tipo" "TipoNovedad" NOT NULL DEFAULT 'GENERAL',
    "prioridad" "PrioridadNovedad" NOT NULL DEFAULT 'MEDIA',
    "estado" "EstadoNovedad" NOT NULL DEFAULT 'ABIERTA',
    "uuid_local" TEXT,
    "coordinadorId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "novedades_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidencias" (
    "id" TEXT NOT NULL,
    "uuid_local" TEXT,
    "visitaId" TEXT,
    "tareaId" TEXT,
    "novedadId" TEXT,
    "uri" TEXT NOT NULL,
    "tipo" "TipoEvidencia" NOT NULL DEFAULT 'FOTOGRAFICA',
    "descripcion" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "evidencias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dispositivos" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "pushToken" TEXT,
    "plataforma" TEXT NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "fechaRegistro" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "dispositivos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sync_operaciones" (
    "id" TEXT NOT NULL,
    "uuid_local" TEXT,
    "entidad" TEXT NOT NULL,
    "accion" "AccionSync" NOT NULL,
    "estado" "EstadoSync" NOT NULL DEFAULT 'PENDIENTE',
    "datos" JSONB,
    "resultadoId" TEXT,
    "resultadoJson" JSONB,
    "errorMensaje" TEXT,
    "intentos" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sync_operaciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evaluaciones_cliente" (
    "id" TEXT NOT NULL,
    "visitaId" TEXT NOT NULL,
    "clienteId" TEXT NOT NULL,
    "coordinadorId" TEXT NOT NULL,
    "puntuacion" INTEGER,
    "comentario" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "evaluaciones_cliente_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "supervisores_usuarioId_key" ON "supervisores"("usuarioId");

-- CreateIndex
CREATE UNIQUE INDEX "coordinadores_usuarioId_key" ON "coordinadores"("usuarioId");

-- CreateIndex
CREATE UNIQUE INDEX "areas_qr_token_key" ON "areas"("qr_token");

-- CreateIndex
CREATE UNIQUE INDEX "cliente_areas_clienteId_areaId_key" ON "cliente_areas"("clienteId", "areaId");

-- CreateIndex
CREATE UNIQUE INDEX "supervisor_areas_supervisorId_areaId_key" ON "supervisor_areas"("supervisorId", "areaId");

-- CreateIndex
CREATE INDEX "sync_operaciones_entidad_accion_estado_idx" ON "sync_operaciones"("entidad", "accion", "estado");

-- CreateIndex
CREATE UNIQUE INDEX "sync_operaciones_uuid_local_entidad_key" ON "sync_operaciones"("uuid_local", "entidad");

-- CreateIndex
CREATE UNIQUE INDEX "evaluaciones_cliente_visitaId_clienteId_key" ON "evaluaciones_cliente"("visitaId", "clienteId");

-- AddForeignKey
ALTER TABLE "supervisores" ADD CONSTRAINT "supervisores_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "coordinadores" ADD CONSTRAINT "coordinadores_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cliente_areas" ADD CONSTRAINT "cliente_areas_clienteId_fkey" FOREIGN KEY ("clienteId") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cliente_areas" ADD CONSTRAINT "cliente_areas_areaId_fkey" FOREIGN KEY ("areaId") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supervisor_areas" ADD CONSTRAINT "supervisor_areas_supervisorId_fkey" FOREIGN KEY ("supervisorId") REFERENCES "supervisores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supervisor_areas" ADD CONSTRAINT "supervisor_areas_areaId_fkey" FOREIGN KEY ("areaId") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitas" ADD CONSTRAINT "visitas_supervisorId_fkey" FOREIGN KEY ("supervisorId") REFERENCES "supervisores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitas" ADD CONSTRAINT "visitas_areaId_fkey" FOREIGN KEY ("areaId") REFERENCES "areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitas" ADD CONSTRAINT "visitas_clienteId_fkey" FOREIGN KEY ("clienteId") REFERENCES "clientes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tareas_revision" ADD CONSTRAINT "tareas_revision_visitaId_fkey" FOREIGN KEY ("visitaId") REFERENCES "visitas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "novedades" ADD CONSTRAINT "novedades_visitaId_fkey" FOREIGN KEY ("visitaId") REFERENCES "visitas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "novedades" ADD CONSTRAINT "novedades_coordinadorId_fkey" FOREIGN KEY ("coordinadorId") REFERENCES "coordinadores"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidencias" ADD CONSTRAINT "evidencias_visitaId_fkey" FOREIGN KEY ("visitaId") REFERENCES "visitas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidencias" ADD CONSTRAINT "evidencias_tareaId_fkey" FOREIGN KEY ("tareaId") REFERENCES "tareas_revision"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidencias" ADD CONSTRAINT "evidencias_novedadId_fkey" FOREIGN KEY ("novedadId") REFERENCES "novedades"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dispositivos" ADD CONSTRAINT "dispositivos_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evaluaciones_cliente" ADD CONSTRAINT "evaluaciones_cliente_visitaId_fkey" FOREIGN KEY ("visitaId") REFERENCES "visitas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evaluaciones_cliente" ADD CONSTRAINT "evaluaciones_cliente_clienteId_fkey" FOREIGN KEY ("clienteId") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evaluaciones_cliente" ADD CONSTRAINT "evaluaciones_cliente_coordinadorId_fkey" FOREIGN KEY ("coordinadorId") REFERENCES "coordinadores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
