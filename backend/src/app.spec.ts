import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './app.module';
import { PrismaService } from './prisma/prisma.service';

describe('App (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  beforeAll(async () => {
    app = await NestFactory.create(AppModule, { logger: ['error'] });
    app.useGlobalPipes(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: true,
        errorHttpStatusCode: 422,
      }),
    );
    await app.init();
    prisma = app.get(PrismaService);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  it('login con password incorrecto devuelve 401', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'coordinador@empresa.com', password: 'wrongpass' })
      .expect(401);
  });

  it('login correcto devuelve accessToken', async () => {
    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'coordinador@empresa.com', password: 'password123' })
      .expect(201);
    expect(res.body.accessToken).toBeDefined();
  });

  it('ruta protegida sin token devuelve 401', async () => {
    await request(app.getHttpServer()).get('/coordinador/supervisores').expect(401);
  });

  it('validacion de DTO rechaza datos invalidos (422)', async () => {
    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'not-an-email', password: 'short' })
      .expect(422);
  });
});
