import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
  NotFoundException,
} from '@nestjs/common';
import { AreaService } from './area.service';
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearAreaDto } from './dto/crear-area.dto';

@ApiTags('areas')
@ApiBearerAuth()
@Controller('areas')
export class AreaController {
  constructor(private readonly areaService: AreaService) {}

  @Get()
  @Roles(Rol.COORDINADOR, Rol.SUPERVISOR)
  findAll() {
    return this.areaService.findAll();
  }

  @Get(':id')
  @Roles(Rol.COORDINADOR, Rol.SUPERVISOR)
  async findOne(@Param('id') id: string) {
    const area = await this.areaService.findOne(id);
    if (!area) throw new NotFoundException('Área no encontrada');
    return area;
  }

  @Post()
  @Roles(Rol.COORDINADOR)
  create(@Body() dto: CrearAreaDto) {
    return this.areaService.create(dto);
  }
}
