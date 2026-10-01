import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsEnum,
  IsUUID,
} from 'class-validator';
import { TipoEvidencia } from '@prisma/client';

export class CrearEvidenciaDto {
  @ApiPropertyOptional({ description: 'URI o ruta de la evidencia', example: 'https://storage.../foto1.jpg' })
  @IsString()
  uri: string;

  @ApiPropertyOptional({ enum: TipoEvidencia, example: TipoEvidencia.FOTOGRAFICA, required: false })
  @IsOptional()
  @IsEnum(TipoEvidencia)
  tipo?: TipoEvidencia;

  @ApiPropertyOptional({ example: 'Foto del baño sucio' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ description: 'UUID local para sync offline' })
  @IsOptional()
  @IsString()
  uuid_local?: string;

  @ApiPropertyOptional({ example: 'visita-uuid', required: false })
  @IsOptional()
  @IsUUID()
  visitaId?: string;

  @ApiPropertyOptional({ example: 'novedad-uuid', required: false })
  @IsOptional()
  @IsUUID()
  novedadId?: string;

  @ApiPropertyOptional({ example: 'tarea-uuid', required: false })
  @IsOptional()
  @IsUUID()
  tareaId?: string;
}
