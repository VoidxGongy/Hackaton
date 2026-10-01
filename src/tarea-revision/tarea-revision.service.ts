import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EstadoTarea } from '@prisma/client';

@Injectable()
export class TareaRevisionService {
  constructor(private prisma: PrismaService) {}

  async marcarEstado(
    tareaId: string,
    supervisorId: string,
    estado: EstadoTarea,
  ) {
    const tarea = await this.prisma.tareaRevision.findUnique({
      where: { id: tareaId },
      include: { visita: true },
    });
    if (!tarea) throw new NotFoundException('Tarea no encontrada');
    if (tarea.visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta tarea');
    }
    return this.prisma.tareaRevision.update({
      where: { id: tareaId },
      data: { estado },
    });
  }

  async crearParaVisita(
    visitaId: string,
    supervisorId: string,
    data: {
      descripcion: string;
      prioridad?: any;
      orden?: number;
      uuid_local?: string;
    },
  ) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: visitaId },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    return this.prisma.tareaRevision.create({
      data: {
        visitaId,
        descripcion: data.descripcion,
        prioridad: data.prioridad ?? 'MEDIA',
        orden: data.orden ?? 0,
        uuid_local: data.uuid_local,
      },
    });
  }
}
