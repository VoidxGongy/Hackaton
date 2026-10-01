import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { DispositivoService } from './dispositivo.service';
import { DispositivoController } from './dispositivo.controller';

@Module({
  imports: [PrismaModule],
  providers: [DispositivoService],
  controllers: [DispositivoController],
  exports: [DispositivoService],
})
export class DispositivoModule {}
