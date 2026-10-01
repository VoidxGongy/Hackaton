import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { CheckinService } from './checkin.service';
import { CheckinController } from './checkin.controller';
import { FcmModule } from '../fcm/fcm.module';
import { DispositivoModule } from '../dispositivo/dispositivo.module';

@Module({
  imports: [PrismaModule, FcmModule, DispositivoModule],
  providers: [CheckinService],
  controllers: [CheckinController],
  exports: [CheckinService],
})
export class CheckinModule {}
