import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';
import { Rol, Usuario } from '@prisma/client';

@Injectable()
export class UsuarioService {
  constructor(private prisma: PrismaService) {}

  async findOne(id: string) {
    return this.prisma.usuario.findUnique({
      where: { id },
      include: { supervisor: true, coordinador: true },
    });
  }

  async findByEmail(email: string) {
    return this.prisma.usuario.findUnique({ where: { email } });
  }

  async create(data: {
    email: string;
    password: string;
    nombre: string;
    rol: Rol;
  }) {
    const hash = await bcrypt.hash(
      data.password,
      Number(process.env.BCRYPT_SALT_ROUNDS) || 12,
    );
    return this.prisma.usuario.create({
      data: {
        email: data.email,
        password: hash,
        nombre: data.nombre,
        rol: data.rol,
        ...(data.rol === Rol.SUPERVISOR
          ? { supervisor: { create: {} } }
          : data.rol === Rol.COORDINADOR
            ? { coordinador: { create: {} } }
            : {}),
      },
      include: { supervisor: true, coordinador: true },
    });
  }

  toPublic(u: Usuario) {
    const { password, ...rest } = u;
    return rest;
  }
}
