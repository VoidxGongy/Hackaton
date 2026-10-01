import { Body, Controller, Post, UseGuards, Request } from '@nestjs/common';
import { SyncService } from './sync.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { SyncLoteDto } from './dto/sync-lote.dto';

@ApiTags('sync')
@ApiBearerAuth()
@Roles(Rol.SUPERVISOR)
@Controller('sync')
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post()
  async sincronizar(@Request() req: AuthenticatedRequest, @Body() dto: SyncLoteDto) {
    return this.syncService.procesarLote(req.user.supervisorId!, dto.operaciones);
  }
}
