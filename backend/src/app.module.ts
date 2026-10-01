import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { AuthModule } from './auth/auth.module';
import { RolesGuard } from './auth/roles.guard';
import { JwtAuthGuard } from './auth/jwt-auth.guard';
import { PrismaModule } from './prisma/prisma.module';
import { UsuarioModule } from './usuario/usuario.module';
import { SupervisorModule } from './supervisor/supervisor.module';
import { CoordinadorModule } from './coordinador/coordinador.module';
import { AreaModule } from './area/area.module';
import { VisitaModule } from './visita/visita.module';
import { TareaRevisionModule } from './tarea-revision/tarea-revision.module';
import { NovedadModule } from './novedad/novedad.module';
import { EvidenciaModule } from './evidencia/evidencia.module';
import { ClienteModule } from './cliente/cliente.module';
import { EvaluacionClienteModule } from './evaluacion-cliente/evaluacion-cliente.module';
import { DispositivoModule } from './dispositivo/dispositivo.module';
import { SyncModule } from './sync/sync.module';
import { FcmModule } from './fcm/fcm.module';
import { CheckinModule } from './checkin/checkin.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsuarioModule,
    SupervisorModule,
    CoordinadorModule,
    AreaModule,
    VisitaModule,
    TareaRevisionModule,
    NovedadModule,
    EvidenciaModule,
    ClienteModule,
    EvaluacionClienteModule,
    DispositivoModule,
    SyncModule,
    FcmModule,
    CheckinModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule {}
