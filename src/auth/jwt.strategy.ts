import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy as JwtStrategyStrategy, ExtractJwt } from 'passport-jwt';
import { jwtConstants } from './constants';
import { PrismaService } from '../prisma/prisma.service';
import { Rol } from '@prisma/client';

export interface JwtPayload {
  sub: string;
  email: string;
  rol: string;
}

export interface AuthenticatedUser {
  sub: string;
  email: string;
  nombre: string;
  rol: Rol;
  supervisorId?: string;
  coordinadorId?: string;
}

@Injectable()
export class JwtAccessStrategy extends PassportStrategy(JwtStrategyStrategy, 'jwt') {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtConstants.accessSecret,
    });
  }

  async validate(payload: JwtPayload): Promise<AuthenticatedUser> {
    const usuario = await this.prisma.usuario.findUnique({
      where: { id: payload.sub },
      include: { supervisor: true, coordinador: true },
    });
    if (!usuario || !usuario.activo) {
      throw new UnauthorizedException('Usuario inválido');
    }
    return {
      sub: usuario.id,
      email: usuario.email,
      nombre: usuario.nombre,
      rol: usuario.rol,
      supervisorId: usuario.supervisor?.id,
      coordinadorId: usuario.coordinador?.id,
    };
  }
}
