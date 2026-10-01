// Load environment variables before the app starts
require('dotenv').config();

import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'error', 'warn', 'debug', 'verbose'],
  });

  app.enableCors();
  app.use(helmet());
  app.use(
    rateLimit({
      windowMs: 1000 * 60,
      max: 300,
      standardHeaders: true,
      legacyHeaders: false,
    }),
  );

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      errorHttpStatusCode: 422,
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('Supervisión Inteligente API')
    .setDescription('API REST para supervisión de visitas en centros de costo')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port, () => {
    console.log(`🚀 Backend escuchando en puerto ${port}`);
    console.log(`📚 Swagger disponible en http://localhost:${port}/docs`);
  });
}
bootstrap();
