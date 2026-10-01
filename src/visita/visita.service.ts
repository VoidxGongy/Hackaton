import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EstadoVisita } from '@prisma/client';

@Injectable()
export class VisitaService {
  constructor(private prisma: PrismaService) {}

  async visitasDelSupervisor(supervisorId: string, filtros?: { estado?: EstadoVisita }) {
    return this.prisma.visita.findMany({
      where: {
        supervisorId,
        ...(filtros?.estado ? { estado: filtros.estado } : {}),
      },
      include: {
        area: true,
        tareas: true,
        novedades: true,
        evidencias: true,
      },
      orderBy: { fechaProgramada: 'asc' },
    });
  }

  async findOneParaSupervisor(visitaId: string, supervisorId: string) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: visitaId },
      include: { area: true, tareas: true, novedades: true, evidencias: true },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    return visita;
  }

  async registrarLlegada(visitaId: string, supervisorId: string, hora: Date) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: visitaId },
      include: { area: true },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    if (visita.estado === EstadoVisita.PROGRAMADA) {
      return this.prisma.visita.update({
        where: { id: visitaId },
        data: { estado: EstadoVisita.EN_CURSO, horaLlegada: hora },
      });
    }
    return this.prisma.visita.update({
      where: { id: visitaId },
      data: { horaLlegada: hora },
    });
  }

  async registrarSalida(visitaId: string, supervisorId: string, hora: Date) {
    const visita = await this.prisma.visita.findUnique({ where: { id: visitaId } });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    return this.prisma.visita.update({
      where: { id: visitaId },
      data: { estado: EstadoVisita.COMPLETADA, horaSalida: hora },
    });
  }
}
