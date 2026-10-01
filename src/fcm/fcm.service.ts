import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);
  private app: admin.app.App | null = null;

  constructor(private prisma: PrismaService) {}

  async onModuleInit() {
    await this.init();
  }

  private async init() {
    const serviceAccount = process.env.FCM_JSON_KEY;
    if (!serviceAccount) {
      this.logger.warn(
        'FCM_JSON_KEY no definida: las notificaciones push estarán deshabilitadas. ' +
          'Configura la variable de entorno con el JSON de credenciales de Firebase.',
      );
      return;
    }
    try {
      const credential: admin.ServiceAccount = JSON.parse(serviceAccount);
      if (admin.apps.length === 0) {
        this.app = admin.initializeApp({
          credential: admin.credential.cert(credential),
        });
      } else {
        this.app = admin.apps[0] as admin.app.App;
      }
      this.logger.log('Firebase Admin inicializado correctamente.');
    } catch (err) {
      this.logger.error(
        `Error inicializando Firebase Admin: ${(err as Error).message}`,
      );
    }
  }

  private ensureApp(): admin.app.App {
    if (!this.app) {
      throw new Error('Firebase Admin no está inicializado');
    }
    return this.app;
  }

  async sendToToken(token: string, title: string, body: string, data?: Record<string, string>) {
    if (!this.app) {
      this.logger.warn('Intento de envío FCM sin inicializar; se ignora.');
      return { skipped: true };
    }
    const message: admin.messaging.Message = {
      token,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { headers: { 'apns-priority': '10' } },
    };
    try {
      const response = await this.ensureApp().messaging().send(message);
      return { ok: true, id: response };
    } catch (err) {
      this.logger.error(`Error enviando FCM a token: ${(err as Error).message}`);
      return { ok: false, error: (err as Error).message };
    }
  }

  async multicast(tokens: string[], title: string, body: string, data?: Record<string, string>) {
    if (!this.app || tokens.length === 0) {
      this.logger.warn('Multicast FCM omitido (no inicializado o sin tokens).');
      return { skipped: true, count: tokens.length };
    }
    const messages: admin.messaging.Message[] = tokens.map((token) => ({
      token,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { headers: { 'apns-priority': '10' } },
    }));
    try {
      const response = await this.ensureApp().messaging().sendEach(messages);
      const failures = response.responses
        .map((r, i) => (r.success ? null : tokens[i]))
        .filter(Boolean) as string[];
      this.logger.log(
        `Multicast FCM: ${response.successCount} ok, ${response.failureCount} fallidos.`,
      );
      return {
        ok: true,
        success: response.successCount,
        failure: response.failureCount,
        invalidTokens: failures,
      };
    } catch (err) {
      this.logger.error(`Error en multicast FCM: ${(err as Error).message}`);
      return { ok: false, error: (err as Error).message };
    }
  }
}
