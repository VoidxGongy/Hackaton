import {
  Body,
  Controller,
  Param,
  Patch,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';
import { TareaRevisionService } from './tarea-revision.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol, EstadoTarea, Prioridad } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearTareaDto } from './dto/crear-tarea.dto';
import { MarcarTareaDto } from './dto/marcar-tarea.dto';

@ApiTags('tareas')
@ApiBearerAuth()
@Roles(Rol.SUPERVISOR)
@Controller('tareas')
export class TareaRevisionController {
  constructor(private readonly tareaService: TareaRevisionService) {}

  @Post('visita/:visitaId')
  crear(@Param('visitaId') visitaId: string, @Request() req: AuthenticatedRequest, @Body() dto: CrearTareaDto) {
    return this.tareaService.crearParaVisita(visitaId, req.user.supervisorId!, {
      descripcion: dto.descripcion,
      prioridad: dto.prioridad,
      orden: dto.orden,
      uuid_local: dto.uuid_local,
    });
  }

  @Patch(':id')
  marcarEstado(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: MarcarTareaDto,
  ) {
    return this.tareaService.marcarEstado(id, req.user.supervisorId!, dto.estado);
  }
}
