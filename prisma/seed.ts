import { PrismaClient, Rol, Prioridad, EstadoVisita } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const SALT = Number(process.env.BCRYPT_SALT_ROUNDS) || 12;

async function main() {
  const passwordHash = await bcrypt.hash('password123', SALT);

  const coordinador = await prisma.usuario.upsert({
    where: { email: 'coordinador@empresa.com' },
    update: { password: passwordHash },
    create: {
      email: 'coordinador@empresa.com',
      password: passwordHash,
      nombre: 'Coordinador Demo',
      rol: Rol.COORDINADOR,
      coordinador: { create: { telefono: '3000000000' } },
    },
  });

  const supervisor = await prisma.usuario.upsert({
    where: { email: 'supervisor@empresa.com' },
    update: { password: passwordHash },
    create: {
      email: 'supervisor@empresa.com',
      password: passwordHash,
      nombre: 'Supervisor Demo',
      rol: Rol.SUPERVISOR,
      supervisor: { create: { numeroIdentificacion: '1000000', telefono: '3001111111' } },
    },
  });

  const supervisorReal = await prisma.supervisor.findUnique({
    where: { usuarioId: supervisor.id },
  });
  const coordinadorReal = await prisma.coordinador.findUnique({
    where: { usuarioId: coordinador.id },
  });

  const areaNombres = ['Edificio Central', 'Torre Norte', 'Conjunto Residencial Sol'];
  const areas = await Promise.all(
    areaNombres.map(async (nombre, i) => {
      const existente = await prisma.area.findFirst({ where: { nombre } });
      if (existente) return existente;
      return prisma.area.create({
        data: {
          nombre,
          descripcion: `Área de costo #${i + 1}`,
          direccion: `Av. Principal #${i + 1}00`,
        },
      });
    }),
  );

  if (supervisorReal) {
    for (const area of areas) {
      await prisma.supervisorArea.upsert({
        where: { supervisorId_areaId: { supervisorId: supervisorReal.id, areaId: area.id } },
        update: {},
        create: { supervisorId: supervisorReal.id, areaId: area.id },
      });
    }
  }

  // Visitas programadas
  await prisma.visita.createMany({
    data: areas.map((area, i) => ({
      supervisorId: supervisorReal!.id,
      areaId: area.id,
      titulo: `Visita programada a ${area.nombre}`,
      descripcion: 'Revisión de servicios de aseo',
      prioridad: i === 0 ? Prioridad.ALTA : Prioridad.MEDIA,
      fechaProgramada: new Date(Date.now() + (i + 1) * 86400000),
      estado: EstadoVisita.PROGRAMADA,
    })),
    skipDuplicates: true,
  });

  console.log('🌱 Seed completado:');
  console.log(' - Coordinador: coordinador@empresa.com / password123');
  console.log(' - Supervisor: supervisor@empresa.com / password123');
  console.log(` - Áreas creadas: ${areas.length}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
