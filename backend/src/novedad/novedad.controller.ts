import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';
import { NovedadService } from './novedad.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol, EstadoNovedad } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearNovedadDto } from './dto/crear-novedad.dto';
import { CambiarEstadoNovedadDto } from './dto/cambiar-estado-novedad.dto';

@ApiTags('novedades')
@ApiBearerAuth()
@Controller('novedades')
export class NovedadController {
  constructor(private readonly novedadService: NovedadService) {}

  @Post('visita/:visitaId')
  @Roles(Rol.SUPERVISOR)
  crear(@Param('visitaId') visitaId: string, @Request() req: AuthenticatedRequest, @Body() dto: CrearNovedadDto) {
    return this.novedadService.crearParaVisita(visitaId, req.user.supervisorId!, dto);
  }

  @Get()
  @Roles(Rol.SUPERVISOR)
  listarPropias(@Request() req: AuthenticatedRequest) {
    return this.novedadService.findAllDeSupervisor(req.user.supervisorId!);
  }

  @Get('coord')
  @Roles(Rol.COORDINADOR)
  listarTodas() {
    return this.novedadService.findAllCoord();
  }

  @Patch(':id/estado')
  @Roles(Rol.COORDINADOR)
  cambiarEstado(@Param('id') id: string, @Body() dto: CambiarEstadoNovedadDto) {
    return this.novedadService.cambiarEstado(id, dto.estado);
  }
}
