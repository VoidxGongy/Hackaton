import {
  Body,
  Controller,
  Post,
  Delete,
  UseGuards,
  Request,
} from '@nestjs/common';
import { DispositivoService } from './dispositivo.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { RegistrarDispositivoDto } from './dto/registrar-dispositivo.dto';

@ApiTags('dispositivos')
@ApiBearerAuth()
@Roles(Rol.SUPERVISOR, Rol.COORDINADOR)
@Controller('dispositivos')
export class DispositivoController {
  constructor(private readonly dispositivoService: DispositivoService) {}

  @Post()
  registrar(@Request() req: AuthenticatedRequest, @Body() dto: RegistrarDispositivoDto) {
    return this.dispositivoService.registrar({
      usuarioId: req.user.sub,
      pushToken: dto.push_token,
      plataforma: dto.plataforma,
    });
  }

  @Delete()
  desactivar(@Request() req: AuthenticatedRequest, @Body() dto: RegistrarDispositivoDto) {
    return this.dispositivoService.desactivar(dto.push_token, req.user.sub);
  }
}
