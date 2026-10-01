import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { SupervisorService } from './supervisor.service';
import { SupervisorController } from './supervisor.controller';

@Module({
  imports: [PrismaModule],
  providers: [SupervisorService],
  controllers: [SupervisorController],
  exports: [SupervisorService],
})
export class SupervisorModule {}
