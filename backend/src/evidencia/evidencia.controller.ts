import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';
import { EvidenciaService } from './evidencia.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol, TipoEvidencia } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearEvidenciaDto } from './dto/crear-evidencia.dto';

@ApiTags('evidencias')
@ApiBearerAuth()
@Controller('evidencias')
export class EvidenciaController {
  constructor(private readonly evidenciaService: EvidenciaService) {}

  @Post()
  @Roles(Rol.SUPERVISOR)
  crear(@Request() req: AuthenticatedRequest, @Body() dto: CrearEvidenciaDto) {
    return this.evidenciaService.crear({
      supervisorId: req.user.supervisorId!,
      visitaId: dto.visitaId,
      novedadId: dto.novedadId,
      tareaId: dto.tareaId,
      uri: dto.uri,
      tipo: dto.tipo,
      descripcion: dto.descripcion,
      uuid_local: dto.uuid_local,
    });
  }

  @Get('visita/:visitaId')
  @Roles(Rol.SUPERVISOR)
  listarDeVisita(@Param('visitaId') visitaId: string, @Request() req: AuthenticatedRequest) {
    return this.evidenciaService.listarDeVisita(visitaId, req.user.supervisorId!);
  }
}
