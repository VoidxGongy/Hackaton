import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { EvidenciaService } from './evidencia.service';
import { EvidenciaController } from './evidencia.controller';

@Module({
  imports: [PrismaModule],
  providers: [EvidenciaService],
  controllers: [EvidenciaController],
  exports: [EvidenciaService],
})
export class EvidenciaModule {}
