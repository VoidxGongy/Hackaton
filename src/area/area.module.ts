import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AreaService } from './area.service';
import { AreaController } from './area.controller';

@Module({
  imports: [PrismaModule],
  providers: [AreaService],
  controllers: [AreaController],
  exports: [AreaService],
})
export class AreaModule {}
