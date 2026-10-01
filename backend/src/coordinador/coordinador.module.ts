import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { CoordinadorService } from './coordinador.service';
import { CoordinadorController } from './coordinador.controller';
import { UsuarioService } from '../usuario/usuario.service';

@Module({
  imports: [PrismaModule],
  providers: [CoordinadorService, UsuarioService],
  controllers: [CoordinadorController],
  exports: [CoordinadorService],
})
export class CoordinadorModule {}
