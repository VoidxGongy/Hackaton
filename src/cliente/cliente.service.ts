import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ClienteService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.cliente.findMany({
      include: {
        clientesAreas: { include: { area: true } },
        evaluaciones: true,
      },
    });
  }

  async findOne(id: string) {
    const c = await this.prisma.cliente.findUnique({
      where: { id },
      include: {
        clientesAreas: { include: { area: true } },
        evaluaciones: true,
      },
    });
    if (!c) throw new NotFoundException('Cliente no encontrado');
    return c;
  }

  async create(data: {
    nombre: string;
    email?: string;
    telefono?: string;
    direccion?: string;
  }) {
    return this.prisma.cliente.create({ data });
  }
}
