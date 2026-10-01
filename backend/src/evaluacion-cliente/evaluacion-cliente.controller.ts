import { Body, Controller, Get, Param, Post, UseGuards, Request } from '@nestjs/common';
import { EvaluacionClienteService } from './evaluacion-cliente.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearEvaluacionDto } from './dto/crear-evaluacion.dto';

@ApiTags('evaluaciones')
@ApiBearerAuth()
@Controller('evaluaciones')
export class EvaluacionClienteController {
  constructor(private readonly evaluacionService: EvaluacionClienteService) {}

  @Post()
  @Roles(Rol.COORDINADOR)
  crear(@Body() dto: CrearEvaluacionDto, @Request() req: AuthenticatedRequest) {
    return this.evaluacionService.crear({
      ...dto,
      coordinadorId: req.user.coordinadorId!,
    });
  }

  @Get('visita/:visitaId')
  @Roles(Rol.COORDINADOR)
  findByVisita(@Param('visitaId') visitaId: string, @Request() req: AuthenticatedRequest) {
    return this.evaluacionService.findByVisita(visitaId, req.user.coordinadorId!);
  }
}
