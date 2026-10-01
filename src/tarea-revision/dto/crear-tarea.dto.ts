import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsInt, Min } from 'class-validator';
import { Prioridad } from '@prisma/client';

export class CrearTareaDto {
  @ApiPropertyOptional({ example: 'Verificar limpieza de baños' })
  @IsString()
  descripcion: string;

  @ApiPropertyOptional({ enum: Prioridad, example: Prioridad.MEDIA })
  @IsOptional()
  @IsEnum(Prioridad)
  prioridad?: Prioridad;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  orden?: number;

  @ApiPropertyOptional({ description: 'UUID local para sincronización offline' })
  @IsOptional()
  @IsString()
  uuid_local?: string;
}
