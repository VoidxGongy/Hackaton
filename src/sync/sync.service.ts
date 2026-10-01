import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, EstadoSync, EstadoVisita, EstadoTarea, EstadoNovedad, AccionSync } from '@prisma/client';

@Injectable()
export class SyncService {
  constructor(private prisma: PrismaService) {}

  /**
   * Recibe el listado de operaciones offline generadas por Flutter,
   * identificadas por `uuid_local`. Cada operación se procesa de forma
   * individual (no hay una transacción gigante) respetando la idempotencia.
   */
  async procesarLote(supervisorId: string, operaciones: SyncOperacionEntrada[]) {
    const results: SyncResultado[] = [];
    for (const op of operaciones) {
      results.push(await this.procesarUna(supervisorId, op));
    }
    return { resultados: results };
  }

  private async procesarUna(
    supervisorId: string,
    op: SyncOperacionEntrada,
  ): Promise<SyncResultado> {
    const { uuid_local, entidad, accion, datos } = op;

    // 1) Idempotencia: si ya existe una operación con el mismo uuid_local+entidad
    //    y está APPLIED o COMPLETED, no se vuelve a procesar.
    const existente = await this.prisma.syncOperacion.findUnique({
      where: { uuid_local_entidad: { uuid_local, entidad } },
    });
    if (existente) {
      if (
        existente.estado === EstadoSync.APPLIED ||
        existente.estado === EstadoSync.COMPLETED ||
        existente.estado === EstadoSync.DUPLICATE
      ) {
        // Devolver el resultado previo sin reprocesar
        return {
          uuid_local,
          entidad,
          accion,
          estado: EstadoSync.DUPLICATE,
          resultadoId: existente.resultadoId ?? undefined,
          mensaje: 'Operación ya procesada previamente',
        };
      }
    }

    // 2) Marcar como RETRY/inicio (reintentos trazables)
    let registro = existente
      ? await this.prisma.syncOperacion.update({
          where: { id: existente.id },
          data: { estado: EstadoSync.RETRY, intentos: { increment: 1 }, datos },
        }
      )
      : await this.prisma.syncOperacion.create({
          data: {
            uuid_local,
            entidad,
            accion: accion as AccionSync,
            estado: EstadoSync.PENDIENTE,
            datos,
            intentos: 0,
          },
        });

    try {
      let resultado: any;
      switch (entidad) {
        case 'Visita':
          resultado = await this.procesarVisita(supervisorId, accion, datos);
          break;
        case 'TareaRevision':
          resultado = await this.procesarTarea(supervisorId, accion, datos);
          break;
        case 'Novedad':
          resultado = await this.procesarNovedad(supervisorId, accion, datos);
          break;
        case 'Evidencia':
          resultado = await this.procesarEvidencia(supervisorId, accion, datos);
          break;
        case 'Dispositivo':
          resultado = await this.procesarDispositivo(supervisorId, accion, datos);
          break;
        default:
          throw new BadRequestException(`Entidad desconocida: ${entidad}`);
      }

      await this.prisma.syncOperacion.update({
        where: { id: registro.id },
        data: {
          estado: EstadoSync.APPLIED,
          resultadoId: String(resultado?.id ?? ''),
          resultadoJson: resultado ? (resultado as object) : undefined,
        },
      });

      return {
        uuid_local,
        entidad,
        accion,
        estado: EstadoSync.APPLIED,
        resultadoId: String(resultado?.id ?? ''),
      };
    } catch (err: any) {
      const mensaje = err?.message ?? 'Error procesando operación';
      const esConflicto =
        err instanceof ConflictException || mensaje.includes('conflicto');
      await this.prisma.syncOperacion.update({
        where: { id: registro.id },
        data: {
          estado: esConflicto ? EstadoSync.CONFLICT : EstadoSync.REJECTED,
          errorMensaje: mensaje,
        },
      });
      return {
        uuid_local,
        entidad,
        accion,
        estado: esConflicto ? EstadoSync.CONFLICT : EstadoSync.REJECTED,
        mensaje,
      };
    }
  }

  private async procesarVisita(supervisorId: string, accion: string, datos: any) {
    const visita = JSON.parse(typeof datos === 'string' ? datos : JSON.stringify(datos));
    if (accion === 'CREAR' || accion === 'CHECK_IN') {
      return this.prisma.visita.create({
        data: {
          supervisorId,
          areaId: visita.areaId,
          titulo: visita.titulo,
          descripcion: visita.descripcion,
          prioridad: visita.prioridad ?? 'MEDIA',
          fechaProgramada: new Date(visita.fechaProgramada),
          estado: EstadoVisita.PROGRAMADA,
          uuid_local: visita.uuid_local,
          horaLlegada: visita.horaLlegada ? new Date(visita.horaLlegada) : undefined,
          horaSalida: visita.horaSalida ? new Date(visita.horaSalida) : undefined,
        },
      });
    }
    if (accion === 'ACTUALIZAR') {
      const existente = await this.prisma.visita.findFirst({
        where: { supervisorId, OR: [{ id: visita.id }, { uuid_local: visita.uuid_local }] },
      });
      if (!existente) throw new BadRequestException('Visita no encontrada');
      return this.prisma.visita.update({
        where: { id: existente.id },
        data: {
          titulo: visita.titulo,
          descripcion: visita.descripcion,
          prioridad: visita.prioridad,
          fechaProgramada: visita.fechaProgramada
            ? new Date(visita.fechaProgramada)
            : existente.fechaProgramada,
          estado: visita.estado ?? existente.estado,
          horaLlegada: visita.horaLlegada ? new Date(visita.horaLlegada) : existente.horaLlegada,
          horaSalida: visita.horaSalida ? new Date(visita.horaSalida) : existente.horaSalida,
        },
      });
    }
    if (accion === 'ELIMINAR') {
      return this.prisma.visita.delete({ where: { id: visita.id } });
    }
    throw new BadRequestException(`Acción no soportada para Visita: ${accion}`);
  }

  private async procesarTarea(supervisorId: string, accion: string, datos: any) {
    const tarea = JSON.parse(typeof datos === 'string' ? datos : JSON.stringify(datos));
    if (accion === 'CREAR') {
      if (!tarea.visitaId && !tarea.uuid_local) {
        throw new BadRequestException('Se requiere visitaId o uuid_local para crear tarea');
      }
      let visitaId = tarea.visitaId;
      if (!visitaId && tarea.uuid_local) {
        const v = await this.prisma.visita.findFirst({
          where: { supervisorId, uuid_local: tarea.uuid_local },
          select: { id: true },
        });
        visitaId = v?.id;
      }
      const visita = await this.prisma.visita.findUnique({
        where: { id: visitaId },
        select: { supervisorId: true },
      });
      if (!visita) throw new BadRequestException('Visita no encontrada');
      if (visita.supervisorId !== supervisorId) {
        throw new ConflictException('La tarea no pertenece a una visita del supervisor');
      }
      return this.prisma.tareaRevision.create({
        data: {
          visitaId,
          descripcion: tarea.descripcion,
          prioridad: tarea.prioridad ?? 'MEDIA',
          orden: tarea.orden ?? 0,
          uuid_local: tarea.uuid_local,
        },
      });
    }
    if (accion === 'ACTUALIZAR') {
      const t = await this.prisma.tareaRevision.findUnique({
        where: { id: tarea.id },
        include: { visita: true },
      });
      if (!t) throw new BadRequestException('Tarea no encontrada');
      if (t.visita.supervisorId !== supervisorId) {
        throw new ConflictException('La tarea no pertenece a una visita del supervisor');
      }
      return this.prisma.tareaRevision.update({
        where: { id: tarea.id },
        data: {
          descripcion: tarea.descripcion,
          prioridad: tarea.prioridad,
          orden: tarea.orden,
          estado: tarea.estado,
          uuid_local: tarea.uuid_local,
        },
      });
    }
    if (accion === 'ELIMINAR') {
      const t = await this.prisma.tareaRevision.findUnique({
        where: { id: tarea.id },
        include: { visita: true },
      });
      if (!t) throw new BadRequestException('Tarea no encontrada');
      if (t.visita.supervisorId !== supervisorId)
        throw new ConflictException('La tarea no pertenece a una visita del supervisor');
      return this.prisma.tareaRevision.delete({ where: { id: tarea.id } });
    }
    throw new BadRequestException(`Acción no soportada para TareaRevision: ${accion}`);
  }

  private async procesarNovedad(supervisorId: string, accion: string, datos: any) {
    const novedad = JSON.parse(typeof datos === 'string' ? datos : JSON.stringify(datos));
    if (accion === 'CREAR') {
      const visita = await this.prisma.visita.findUnique({
        where: { id: novedad.visitaId },
        select: { supervisorId: true },
      });
      if (!visita) throw new BadRequestException('Visita no encontrada');
      if (visita.supervisorId !== supervisorId)
        throw new ConflictException('La novedad no pertenece a una visita del supervisor');
      return this.prisma.novedad.create({
        data: {
          visitaId: novedad.visitaId,
          titulo: novedad.titulo,
          descripcion: novedad.descripcion,
          tipo: novedad.tipo ?? 'GENERAL',
          prioridad: novedad.prioridad ?? 'MEDIA',
          uuid_local: novedad.uuid_local,
        },
      });
    }
    if (accion === 'ACTUALIZAR') {
      const n = await this.prisma.novedad.findUnique({
        where: { id: novedad.id },
        include: { visita: true },
      });
      if (!n) throw new BadRequestException('Novedad no encontrada');
      if (n.visita.supervisorId !== supervisorId)
        throw new ConflictException('La novedad no pertenece a una visita del supervisor');
      return this.prisma.novedad.update({
        where: { id: novedad.id },
        data: {
          titulo: novedad.titulo,
          descripcion: novedad.descripcion,
          tipo: novedad.tipo,
          prioridad: novedad.prioridad,
          estado: novedad.estado,
          uuid_local: novedad.uuid_local,
        },
      });
    }
    throw new BadRequestException(`Acción no soportada para Novedad: ${accion}`);
  }

  private async procesarEvidencia(supervisorId: string, accion: string, datos: any) {
    const evidencia = JSON.parse(typeof datos === 'string' ? datos : JSON.stringify(datos));
    if (accion === 'CREAR') {
      if (!evidencia.visitaId && !evidencia.novedadId && !evidencia.tareaId) {
        throw new BadRequestException('Se requiere visitaId, novedadId o tareaId');
      }
      let visitaId = evidencia.visitaId;
      // validar pertenencia mediante la relación
      let visita: { supervisorId: string } | null = null;
      if (visitaId) {
        visita = await this.prisma.visita.findUnique({
          where: { id: visitaId },
          select: { supervisorId: true },
        });
      } else if (evidencia.novedadId) {
        const n = await this.prisma.novedad.findUnique({
          where: { id: evidencia.novedadId },
          include: { visita: { select: { supervisorId: true } } },
        });
        if (n) visita = n.visita;
      } else if (evidencia.tareaId) {
        const t = await this.prisma.tareaRevision.findUnique({
          where: { id: evidencia.tareaId },
          include: { visita: { select: { supervisorId: true } } },
        });
        if (t) visita = t.visita;
      }
      if (!visita) throw new BadRequestException('Entidad asociada no encontrada');
      if (visita.supervisorId !== supervisorId)
        throw new ConflictException('La evidencia no pertenece a una visita del supervisor');
      return this.prisma.evidencia.create({
        data: {
          visitaId: visitaId ?? undefined,
          novedadId: evidencia.novedadId,
          tareaId: evidencia.tareaId,
          uri: evidencia.uri,
          tipo: evidencia.tipo ?? 'FOTOGRAFICA',
          descripcion: evidencia.descripcion,
          uuid_local: evidencia.uuid_local,
        },
      });
    }
    throw new BadRequestException(`Acción no soportada para Evidencia: ${accion}`);
  }

  private async procesarDispositivo(supervisorId: string, accion: string, datos: any) {
    const d = JSON.parse(typeof datos === 'string' ? datos : JSON.stringify(datos));
    if (accion === 'ACTUALIZAR' || accion === 'CREAR') {
      return this.prisma.dispositivo.upsert({
        where: { usuarioId_pushToken: { usuarioId: supervisorId, pushToken: d.pushToken } },
        update: { activo: true, plataforma: d.plataforma ?? 'desconocida' },
        create: {
          usuarioId: supervisorId,
          pushToken: d.pushToken,
          plataforma: d.plataforma ?? 'desconocida',
          activo: true,
        },
      });
    }
    if (accion === 'ELIMINAR') {
      return this.prisma.dispositivo.updateMany({
        where: { usuarioId: supervisorId, pushToken: d.pushToken },
        data: { activo: false },
      });
    }
    throw new BadRequestException(`Acción no soportada para Dispositivo: ${accion}`);
  }
}

export interface SyncOperacionEntrada {
  uuid_local: string;
  entidad: string;
  accion: string;
  datos?: any;
}

export interface SyncResultado {
  uuid_local: string;
  entidad: string;
  accion: string;
  estado: EstadoSync;
  resultadoId?: string;
  mensaje?: string;
}
