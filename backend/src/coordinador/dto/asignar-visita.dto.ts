import { ApiProperty } from '@nestjs/swagger';
import {
  IsEnum,
  IsDateString,
  IsString,
  IsOptional,
  IsUUID,
} from 'class-validator';
import { Prioridad } from '@prisma/client';

export class AsignarVisitaDto {
  @ApiProperty({ example: 'supervisor-uuid' })
  @IsUUID()
  supervisorId: string;

  @ApiProperty({ example: 'area-uuid' })
  @IsUUID()
  areaId: string;

  @ApiProperty({ example: 'Visita a Edificio Central' })
  @IsString()
  titulo: string;

  @ApiProperty({ example: 'Revisar aseo de baños', required: false })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiProperty({ enum: Prioridad, example: Prioridad.MEDIA, required: false })
  @IsOptional()
  @IsEnum(Prioridad)
  prioridad?: Prioridad;

  @ApiProperty({ example: '2026-10-10T09:00:00.000Z' })
  @IsDateString()
  fechaProgramada: string;

  @ApiProperty({ example: 'cliente-uuid', required: false })
  @IsOptional()
  @IsUUID()
  clienteId?: string;
}
