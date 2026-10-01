import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { NovedadService } from './novedad.service';
import { NovedadController } from './novedad.controller';

@Module({
  imports: [PrismaModule],
  providers: [NovedadService],
  controllers: [NovedadController],
  exports: [NovedadService],
})
export class NovedadModule {}
