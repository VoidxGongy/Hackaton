import {
  Body,
  Controller,
  Param,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';
import { CheckinService } from './checkin.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CheckinDto } from './dto/checkin.dto';

@ApiTags('checkin')
@ApiBearerAuth()
@Roles(Rol.SUPERVISOR)
@Controller('checkin')
export class CheckinController {
  constructor(private readonly checkinService: CheckinService) {}

  @Post(':visitaId')
  async checkIn(
    @Param('visitaId') visitaId: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: CheckinDto,
  ) {
    return this.checkinService.checkIn(req.user.supervisorId!, visitaId, dto.qr_token);
  }
}
