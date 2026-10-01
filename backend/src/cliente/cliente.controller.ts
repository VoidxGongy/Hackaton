import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ClienteService } from './cliente.service';
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CrearClienteDto } from './dto/crear-cliente.dto';

@ApiTags('clientes')
@ApiBearerAuth()
@Controller('clientes')
export class ClienteController {
  constructor(private readonly clienteService: ClienteService) {}

  @Get()
  @Roles(Rol.COORDINADOR)
  findAll() {
    return this.clienteService.findAll();
  }

  @Get(':id')
  @Roles(Rol.COORDINADOR)
  findOne(@Param('id') id: string) {
    return this.clienteService.findOne(id);
  }

  @Post()
  @Roles(Rol.COORDINADOR)
  create(@Body() dto: CrearClienteDto) {
    return this.clienteService.create(dto);
  }
}
