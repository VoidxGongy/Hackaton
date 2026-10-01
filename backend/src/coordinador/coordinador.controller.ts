import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { CoordinadorService } from './coordinador.service';
import { Roles } from '../auth/roles.decorator';
import { Rol, Prioridad } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearSupervisorDto } from './dto/crear-supervisor.dto';
import { AsignarVisitaDto } from './dto/asignar-visita.dto';
import { AsignarSupervisorAreaDto } from './dto/asignar-supervisor-area.dto';

@ApiTags('coordinador')
@ApiBearerAuth()
@Roles(Rol.COORDINADOR)
@Controller('coordinador')
export class CoordinadorController {
  constructor(private readonly coordinadorService: CoordinadorService) {}

  @Post('supervisores')
  async crearSupervisor(@Body() dto: CrearSupervisorDto) {
    return this.coordinadorService.crearSupervisor({
      ...dto,
      password: dto.password,
    });
  }

  @Get('supervisores')
  findAllSupervisores() {
    return this.coordinadorService.findAllSupervisores();
  }

  @Get('supervisores/:id')
  findOneSupervisor(@Param('id') id: string) {
    return this.coordinadorService.findOneSupervisor(id);
  }

  @Post('areas/:areaId/supervisores/:supervisorId')
  async asignarSupervisorArea(
    @Param('areaId') areaId: string,
    @Param('supervisorId') supervisorId: string,
  ) {
    const dto = new AsignarSupervisorAreaDto();
    dto.supervisorId = supervisorId;
    dto.areaId = areaId;
    return this.coordinadorService.asignarSupervisorArea(dto.supervisorId, dto.areaId);
  }

  @Post('visitas')
  async asignarVisita(@Body() dto: AsignarVisitaDto) {
    if (new Date(dto.fechaProgramada) < new Date()) {
      throw new BadRequestException('La fecha programada no puede ser en el pasado');
    }
    return this.coordinadorService.asignarVisita({
      supervisorId: dto.supervisorId,
      areaId: dto.areaId,
      titulo: dto.titulo,
      descripcion: dto.descripcion,
      clienteId: dto.clienteId,
      prioridad: dto.prioridad ?? Prioridad.MEDIA,
      fechaProgramada: new Date(dto.fechaProgramada),
    });
  }

  @Get('visitas/pendientes')
  visitasPendientes() {
    return this.coordinadorService.visitasPendientes();
  }

  @Get('visitas/completadas')
  visitasCompletadas() {
    return this.coordinadorService.visitasCompletadas();
  }

  @Get('visitas/historial')
  historialVisitas() {
    return this.coordinadorService.historialVisitas();
  }
}
