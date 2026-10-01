import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class EvaluacionClienteService {
  constructor(private prisma: PrismaService) {}

  async crear(data: {
    visitaId: string;
    clienteId: string;
    coordinadorId: string;
    puntuacion?: number;
    comentario?: string;
  }) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: data.visitaId },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    const cliente = await this.prisma.cliente.findUnique({
      where: { id: data.clienteId },
    });
    if (!cliente) throw new NotFoundException('Cliente no encontrado');
    const coordinador = await this.prisma.coordinador.findUnique({
      where: { id: data.coordinadorId },
    });
    if (!coordinador) throw new NotFoundException('Coordinador no encontrado');

    return this.prisma.evaluacionCliente.create({
      data: {
        visitaId: data.visitaId,
        clienteId: data.clienteId,
        coordinadorId: data.coordinadorId,
        puntuacion: data.puntuacion,
        comentario: data.comentario,
      },
    });
  }

  async findByVisita(visitaId: string, coordinadorId: string) {
    const visita = await this.prisma.visita.findUnique({ where: { id: visitaId } });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    const esCoordinador = await this.prisma.coordinador.findFirst({
      where: { usuarioId: coordinadorId },
      select: { id: true },
    });
    if (!esCoordinador) {
      throw new BadRequestException('Solo coordinadores pueden ver evaluaciones');
    }
    return this.prisma.evaluacionCliente.findMany({
      where: { visitaId },
      include: { cliente: true, coordinador: true },
    });
  }
}
