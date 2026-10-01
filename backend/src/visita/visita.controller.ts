import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
  Request,
  NotFoundException,
} from '@nestjs/common';
import { VisitaService } from './visita.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol, EstadoVisita } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { RegistrarHoraDto } from './dto/registrar-hora.dto';

@ApiTags('visitas')
@ApiBearerAuth()
@Roles(Rol.SUPERVISOR)
@Controller('visitas')
export class VisitaController {
  constructor(private readonly visitaService: VisitaService) {}

  @Get()
  async listar(@Request() req: AuthenticatedRequest, @Query('estado') estado?: EstadoVisita) {
    return this.visitaService.visitasDelSupervisor(req.user.supervisorId!, { estado });
  }

  @Get(':id')
  async detalle(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.visitaService.findOneParaSupervisor(id, req.user.supervisorId!);
  }

  @Post(':id/llegada')
  async registrarLlegada(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: RegistrarHoraDto,
  ) {
    const hora = dto.hora ? new Date(dto.hora) : new Date();
    return this.visitaService.registrarLlegada(id, req.user.supervisorId!, hora);
  }

  @Post(':id/salida')
  async registrarSalida(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: RegistrarHoraDto,
  ) {
    const hora = dto.hora ? new Date(dto.hora) : new Date();
    return this.visitaService.registrarSalida(id, req.user.supervisorId!, hora);
  }
}
