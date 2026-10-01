import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DispositivoService {
  constructor(private prisma: PrismaService) {}

  async registrar(data: {
    usuarioId: string;
    pushToken: string;
    plataforma: string;
  }) {
    return this.prisma.dispositivo.upsert({
      where: {
        usuarioId_pushToken: {
          usuarioId: data.usuarioId,
          pushToken: data.pushToken,
        },
      },
      update: { activo: true },
      create: {
        usuarioId: data.usuarioId,
        pushToken: data.pushToken,
        plataforma: data.plataforma,
        activo: true,
      },
    });
  }

  async desactivar(pushToken: string, usuarioId: string) {
    return this.prisma.dispositivo.updateMany({
      where: { usuarioId, pushToken },
      data: { activo: false },
    });
  }

  async pushTokensDelCoordinador(): Promise<string[]> {
    const tokens = await this.prisma.dispositivo.findMany({
      where: {
        activo: true,
        usuario: { rol: 'COORDINADOR' },
        pushToken: { not: null },
      },
      select: { pushToken: true },
    });
    return tokens
      .map((t) => t.pushToken)
      .filter((t): t is string => Boolean(t));
  }
}
