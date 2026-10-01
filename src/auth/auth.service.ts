import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { jwtConstants } from './constants';
import * as bcrypt from 'bcryptjs';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  async validateCredentials(email: string, password: string) {
    const usuario = await this.prisma.usuario.findUnique({
      where: { email },
      include: { supervisor: true, coordinador: true },
    });
    if (!usuario) return null;
    const valid = await bcrypt.compare(password, usuario.password);
    if (!valid) return null;
    return usuario;
  }

  async login(dto: LoginDto) {
    const usuario = await this.validateCredentials(dto.email, dto.password);
    if (!usuario) throw new UnauthorizedException('Credenciales inválidas');

    const payload: JwtPayload = {
      sub: usuario.id,
      email: usuario.email,
      rol: usuario.rol,
    };
    const accessToken = await this.jwt.signAsync(payload, {
      secret: jwtConstants.accessSecret,
      expiresIn: jwtConstants.accessExpiresIn,
    } as any);
    const refreshToken = await this.jwt.signAsync(payload, {
      secret: jwtConstants.refreshSecret,
      expiresIn: jwtConstants.refreshExpiresIn,
    } as any);
    return {
      accessToken,
      refreshToken,
      usuario: {
        id: usuario.id,
        email: usuario.email,
        nombre: usuario.nombre,
        rol: usuario.rol,
      },
    };
  }

  async refresh(refreshToken: string) {
    try {
      const payload = await this.jwt.verifyAsync<JwtPayload>(refreshToken, {
        secret: jwtConstants.refreshSecret,
      });
      const usuario = await this.prisma.usuario.findUnique({
        where: { id: payload.sub },
        include: { supervisor: true, coordinador: true },
      });
      if (!usuario || !usuario.activo) {
        throw new UnauthorizedException('Usuario inválido');
      }
      const newPayload: JwtPayload = {
        sub: usuario.id,
        email: usuario.email,
        rol: usuario.rol,
      };
      const accessToken = await this.jwt.signAsync(newPayload, {
        secret: jwtConstants.accessSecret,
        expiresIn: jwtConstants.accessExpiresIn,
      } as any);
      return { accessToken };
    } catch {
      throw new UnauthorizedException('Refresh token inválido');
    }
  }

  async logout(refreshToken: string) {
    // Refresh tokens are stateless; revocation handled by client removing token.
    // For server-side revocation we could blacklist, but for hackathon we
    // return success and rely on token expiry.
    return { ok: true };
  }
}
