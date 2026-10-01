import {
  Controller,
  Get,
  Param,
  UseGuards,
  NotFoundException,
} from '@nestjs/common';
import { SupervisorService } from './supervisor.service';
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('supervisores')
@ApiBearerAuth()
@Roles(Rol.COORDINADOR)
@Controller('supervisores')
export class SupervisorController {
  constructor(private readonly supervisorService: SupervisorService) {}

  @Get()
  async findAll() {
    return this.supervisorService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const s = await this.supervisorService.findOne(id);
    if (!s) throw new NotFoundException('Supervisor no encontrado');
    return s;
  }
}