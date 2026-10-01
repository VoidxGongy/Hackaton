import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { UsuarioService } from './usuario.service';
import { AuthenticatedRequest } from "../shared/authenticated-request";
import { Roles } from '../auth/roles.decorator';
import { Rol } from '@prisma/client';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('usuarios')
@ApiBearerAuth()
@Controller('usuarios')
export class UsuarioController {
  constructor(private readonly usuarioService: UsuarioService) {}

  @Get('me')
  @Roles(Rol.SUPERVISOR, Rol.COORDINADOR)
  getProfile(@Request() req: AuthenticatedRequest) {
    return req.user;
  }
}