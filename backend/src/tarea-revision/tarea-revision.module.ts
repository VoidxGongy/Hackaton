import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { TareaRevisionService } from './tarea-revision.service';
import { TareaRevisionController } from './tarea-revision.controller';

@Module({
  imports: [PrismaModule],
  providers: [TareaRevisionService],
  controllers: [TareaRevisionController],
  exports: [TareaRevisionService],
})
export class TareaRevisionModule {}
