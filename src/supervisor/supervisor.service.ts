import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SupervisorService {
  constructor(private prisma: PrismaService) {}

  async findOne(id: string) {
    return this.prisma.supervisor.findUnique({
      where: { id },
      include: {
        usuario: { select: { id: true, email: true, nombre: true, rol: true } },
        supervisorAreas: { include: { area: true } },
      },
    });
  }

  async findAll() {
    return this.prisma.supervisor.findMany({
      include: {
        usuario: { select: { id: true, email: true, nombre: true, rol: true } },
        supervisorAreas: { include: { area: true } },
      },
    });
  }
}
