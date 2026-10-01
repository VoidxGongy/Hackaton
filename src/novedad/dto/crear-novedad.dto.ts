import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { TipoNovedad, PrioridadNovedad } from '@prisma/client';

export class CrearNovedadDto {
  @ApiPropertyOptional({ example: 'Fuga de agua en baño' })
  @IsString()
  titulo: string;

  @ApiPropertyOptional({ example: 'Se observa una fuga...', required: false })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ enum: TipoNovedad, example: TipoNovedad.CRITICA, required: false })
  @IsOptional()
  @IsEnum(TipoNovedad)
  tipo?: TipoNovedad;

  @ApiPropertyOptional({
    enum: PrioridadNovedad,
    example: PrioridadNovedad.ALTA,
    required: false,
  })
  @IsOptional()
  @IsEnum(PrioridadNovedad)
  prioridad?: PrioridadNovedad;

  @ApiPropertyOptional({ description: 'UUID local para sync offline' })
  @IsOptional()
  @IsString()
  uuid_local?: string;
}
