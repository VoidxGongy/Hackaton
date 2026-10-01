import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class EvidenciaService {
  constructor(private prisma: PrismaService) {}

  async crear(data: {
    supervisorId: string;
    visitaId?: string;
    novedadId?: string;
    tareaId?: string;
    uri: string;
    tipo?: any;
    descripcion?: string;
    uuid_local?: string;
  }) {
    const evidenciaData: any = {
      uri: data.uri,
      tipo: data.tipo ?? 'FOTOGRAFICA',
      descripcion: data.descripcion,
      uuid_local: data.uuid_local,
    };

    if (data.visitaId) {
      const visita = await this.prisma.visita.findUnique({
        where: { id: data.visitaId },
      });
      if (!visita) throw new NotFoundException('Visita no encontrada');
      if (visita.supervisorId !== data.supervisorId) {
        throw new BadRequestException('No tienes acceso a esta visita');
      }
      evidenciaData.visitaId = data.visitaId;
    }

    if (data.novedadId) {
      const novedad = await this.prisma.novedad.findUnique({
        where: { id: data.novedadId },
        include: { visita: true },
      });
      if (!novedad) throw new NotFoundException('Novedad no encontrada');
      if (novedad.visita.supervisorId !== data.supervisorId) {
        throw new BadRequestException('No tienes acceso a esta novedad');
      }
      evidenciaData.novedadId = data.novedadId;
    }

    if (data.tareaId) {
      const tarea = await this.prisma.tareaRevision.findUnique({
        where: { id: data.tareaId },
        include: { visita: true },
      });
      if (!tarea) throw new NotFoundException('Tarea no encontrada');
      if (tarea.visita.supervisorId !== data.supervisorId) {
        throw new BadRequestException('No tienes acceso a esta tarea');
      }
      evidenciaData.tareaId = data.tareaId;
    }

    return this.prisma.evidencia.create({ data: evidenciaData });
  }

  async listarDeVisita(visitaId: string, supervisorId: string) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: visitaId },
      include: { evidencias: true },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    return visita.evidencias;
  }
}
