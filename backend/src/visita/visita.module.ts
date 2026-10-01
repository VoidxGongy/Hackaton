import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { VisitaService } from './visita.service';
import { VisitaController } from './visita.controller';

@Module({
  imports: [PrismaModule],
  providers: [VisitaService],
  controllers: [VisitaController],
  exports: [VisitaService],
})
export class VisitaModule {}
