import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Area } from '@prisma/client';

@Injectable()
export class AreaService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.area.findMany({
      include: { clientes: { include: { cliente: true } } },
    });
  }

  async findOne(id: string) {
    return this.prisma.area.findUnique({
      where: { id },
      include: { clientes: { include: { cliente: true } } },
    });
  }

  async findByQr(qrToken: string) {
    return this.prisma.area.findUnique({
      where: { qr_token: qrToken },
      include: { clientes: { include: { cliente: true } } },
    });
  }

  async create(data: {
    nombre: string;
    descripcion?: string;
    direccion?: string;
    clienteId?: string;
  }): Promise<Area> {
    return this.prisma.area.create({
      data: {
        nombre: data.nombre,
        descripcion: data.descripcion,
        direccion: data.direccion,
        ...(data.clienteId
          ? {
              clientes: {
                create: { clienteId: data.clienteId },
              },
            }
          : {}),
      },
    });
  }
}
