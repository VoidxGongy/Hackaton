import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FcmService } from '../fcm/fcm.service';
import { EstadoVisita } from '@prisma/client';
import { DispositivoService } from '../dispositivo/dispositivo.service';

@Injectable()
export class CheckinService {
  constructor(
    private prisma: PrismaService,
    private fcm: FcmService,
    private dispositivoService: DispositivoService,
  ) {}

  // Import DispositivoService lazily through the module
  async checkIn(supervisorId: string, visitaId: string, qrToken: string) {
    const visita = await this.prisma.visita.findUnique({
      where: { id: visitaId },
      include: { area: true, supervisor: true },
    });
    if (!visita) throw new NotFoundException('Visita no encontrada');
    if (visita.supervisorId !== supervisorId) {
      throw new BadRequestException('Solo puedes hacer check-in de tus propias visitas');
    }

    const area = await this.prisma.area.findUnique({
      where: { qr_token: qrToken },
    });
    if (!area) throw new NotFoundException('QR inválido: área no encontrada');

    if (visita.areaId !== area.id) {
      throw new ConflictException(
        `El QR corresponde al área "${area.nombre}" pero la visita es del área "${visita.area.nombre ?? ''}"`.trim(),
      );
    }

    if (visita.estado !== EstadoVisita.PROGRAMADA && visita.estado !== EstadoVisita.EN_CURSO) {
      throw new ConflictException(
        `No se puede hacer check-in cuando la visita está ${visita.estado}`,
      );
    }

    const horaLlegada = new Date();
    // Transacción atómica: commit del check-in
    await this.prisma.$transaction(async (tx) => {
      await tx.visita.update({
        where: { id: visita.id },
        data: {
          estado: EstadoVisita.EN_CURSO,
          horaLlegada: horaLlegada,
        },
      });

      await tx.syncOperacion.create({
        data: {
          uuid_local: `checkin-${visita.id}-${horaLlegada.getTime()}`,
          entidad: 'Visita',
          accion: 'CHECK_IN',
          estado: 'COMPLETED',
          datos: { visitaId: visita.id, qrToken, horaLlegada: horaLlegada.toISOString() },
          resultadoId: visita.id,
        },
      });
    });

    // Notificar al coordinador vía FCM (fuera de la transacción; si falla NO se revierte)
    await this.notificarCheckin(visita);

    return {
      ok: true,
      visitaId: visita.id,
      areaId: area.id,
      areaNombre: area.nombre,
      horaLlegada,
      estado: EstadoVisita.EN_CURSO,
    };
  }

  private async notificarCheckin(visita: any) {
    try {
      const pushTokens = await this.dispositivoService.pushTokensDelCoordinador();
      const titulo = `Check-in: ${visita.supervisor.usuario?.nombre ?? 'Supervisor'}`;
      const cuerpo = `El supervisor ha iniciado la visita en ${visita.area?.nombre ?? 'área'}`.trim();
      if (pushTokens.length === 0) return;
      await this.fcm.multicast(pushTokens, titulo, cuerpo, {
        visitaId: visita.id,
        tipo: 'CHECK_IN',
      });
    } catch (err) {
      // FCM falló, pero el check-in ya se confirmó en BD. Solo logueamos (sin tokens).
      console.warn('Notificación FCM fallida (check-in preservado):', (err as Error).message);
    }
  }
}
