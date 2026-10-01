import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { EvaluacionClienteService } from './evaluacion-cliente.service';
import { EvaluacionClienteController } from './evaluacion-cliente.controller';

@Module({
  imports: [PrismaModule],
  providers: [EvaluacionClienteService],
  controllers: [EvaluacionClienteController],
})
export class EvaluacionClienteModule {}
