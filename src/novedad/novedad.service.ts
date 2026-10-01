import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { EstadoNovedad } from '@prisma/client';

@Injectable()
export class NovedadService {
  constructor(private prisma: PrismaService) {}

  async crearParaVisita(
    visitaId: string,
    supervisorId: string,
    data: {
      titulo: string;
      descripcion?: string;
      tipo?: any;
      prioridad?: any;
      uuid_local?: string;
    },
  ) {
    const visita = await this.prisma.visita.findUnique({ where: { id: visitaId } });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('No tienes acceso a esta visita');
    }
    return this.prisma.novedad.create({
      data: {
        visitaId,
        titulo: data.titulo,
        descripcion: data.descripcion,
        tipo: data.tipo ?? 'GENERAL',
        prioridad: data.prioridad ?? 'MEDIA',
        uuid_local: data.uuid_local,
      },
      include: { evidencias: true },
    });
  }

  async findAllDeSupervisor(supervisorId: string) {
    return this.prisma.novedad.findMany({
      where: {
        visita: { supervisorId },
      },
      include: { evidencias: true, visita: { include: { area: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async cambiarEstado(novedadId: string, estado: EstadoNovedad) {
    const novedad = await this.prisma.novedad.findUnique({
      where: { id: novedadId },
    });
    if (!novedad) throw new NotFoundException('Novedad no encontrada');
    return this.prisma.novedad.update({
      where: { id: novedadId },
      data: { estado },
    });
  }

  async findAllCoord() {
    return this.prisma.novedad.findMany({
      orderBy: { createdAt: 'desc' },
      include: { evidencias: true, visita: { include: { area: true, supervisor: { include: { usuario: true } } } } },
    });
  }
}
