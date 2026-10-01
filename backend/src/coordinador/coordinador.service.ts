import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsuarioService } from '../usuario/usuario.service';
import { Rol, Prioridad, EstadoVisita } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class CoordinadorService {
  constructor(
    private prisma: PrismaService,
    private usuarioService: UsuarioService,
  ) {}

  async crearSupervisor(payload: {
    email: string;
    password: string;
    nombre: string;
    numeroIdentificacion?: string;
    telefono?: string;
  }) {
    const exists = await this.usuarioService.findByEmail(payload.email);
    if (exists) throw new BadRequestException('Email ya registrado');
    return this.prisma.usuario.create({
      data: {
        email: payload.email,
        password: await bcrypt.hash(
          payload.password,
          Number(process.env.BCRYPT_SALT_ROUNDS) || 12,
        ),
        nombre: payload.nombre,
        rol: Rol.SUPERVISOR,
        supervisor: {
          create: {
            numeroIdentificacion: payload.numeroIdentificacion,
            telefono: payload.telefono,
          },
        },
      },
      select: {
        id: true,
        email: true,
        nombre: true,
        rol: true,
        activo: true,
        supervisor: { select: { id: true, numeroIdentificacion: true, telefono: true } },
      },
    });
  }

  async findAllSupervisores() {
    return this.prisma.supervisor.findMany({
      include: {
        usuario: {
          select: { id: true, email: true, nombre: true, rol: true, activo: true },
        },
        supervisorAreas: { include: { area: true } },
      },
    });
  }

  async findOneSupervisor(id: string) {
    const s = await this.prisma.supervisor.findUnique({
      where: { id },
      include: {
        usuario: {
          select: { id: true, email: true, nombre: true, rol: true, activo: true },
        },
        supervisorAreas: { include: { area: true } },
      },
    });
    if (!s) throw new NotFoundException('Supervisor no encontrado');
    return s;
  }

  async asignarSupervisorArea(supervisorId: string, areaId: string) {
    const supervisor = await this.prisma.supervisor.findUnique({
      where: { id: supervisorId },
    });
    if (!supervisor) throw new NotFoundException('Supervisor no encontrado');
    const area = await this.prisma.area.findUnique({ where: { id: areaId } });
    if (!area) throw new NotFoundException('Área no encontrada');

    return this.prisma.supervisorArea.upsert({
      where: { supervisorId_areaId: { supervisorId, areaId } },
      update: {},
      create: { supervisorId, areaId },
    });
  }

  async asignarVisita(data: {
    supervisorId: string;
    areaId: string;
    titulo: string;
    fechaProgramada: Date;
    prioridad: Prioridad;
    clienteId?: string;
    descripcion?: string;
  }) {
    const supervisor = await this.prisma.supervisor.findUnique({
      where: { id: data.supervisorId },
    });
    if (!supervisor) throw new NotFoundException('Supervisor no encontrado');
    const area = await this.prisma.area.findUnique({ where: { id: data.areaId } });
    if (!area) throw new NotFoundException('Área no encontrada');

    return this.prisma.visita.create({
      data: {
        supervisorId: data.supervisorId,
        areaId: data.areaId,
        clienteId: data.clienteId,
        titulo: data.titulo,
        descripcion: data.descripcion,
        prioridad: data.prioridad,
        fechaProgramada: data.fechaProgramada,
        estado: EstadoVisita.PROGRAMADA,
      },
      include: { area: true, supervisor: { include: { usuario: true } } },
    });
  }

  async visitasPendientes() {
    return this.prisma.visita.findMany({
      where: { estado: EstadoVisita.PROGRAMADA },
      include: { area: true, supervisor: { include: { usuario: true } } },
    });
  }

  async visitasCompletadas() {
    return this.prisma.visita.findMany({
      where: { estado: EstadoVisita.COMPLETADA },
      include: { area: true, supervisor: { include: { usuario: true } } },
    });
  }

  async historialVisitas() {
    return this.prisma.visita.findMany({
      where: {
        OR: [{ estado: EstadoVisita.COMPLETADA }, { estado: EstadoVisita.EN_CURSO }],
      },
      orderBy: { fechaProgramada: 'desc' },
      include: {
        area: true,
        supervisor: { include: { usuario: true } },
        novedades: true,
        evidencias: true,
      },
    });
  }
}
