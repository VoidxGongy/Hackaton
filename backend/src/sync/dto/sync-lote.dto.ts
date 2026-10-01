import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsArray,
  ValidateNested,
  IsOptional,
  IsObject,
  IsIn,
} from 'class-validator';
import { Type } from 'class-transformer';

export class SyncOperacionDto {
  @ApiProperty({ example: '11111111-2222-3333-4444-555555555555' })
  @IsString()
  uuid_local: string;

  @ApiProperty({ example: 'Visita' })
  @IsString()
  entidad: string;

  @ApiProperty({ enum: ['CREAR', 'ACTUALIZAR', 'ELIMINAR', 'CHECK_IN'] })
  @IsIn(['CREAR', 'ACTUALIZAR', 'ELIMINAR', 'CHECK_IN'])
  accion: string;

  @ApiPropertyOptional({
    description: 'Datos de la operación. Puede ser string JSON u objeto.',
    example: { titulo: 'Visita', areaId: 'uuid', fechaProgramada: '2026-10-10T09:00:00.000Z' },
  })
  @IsOptional()
  @IsObject()
  datos?: Record<string, any>;
}

export class SyncLoteDto {
  @ApiProperty({ type: [SyncOperacionDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SyncOperacionDto)
  operaciones: SyncOperacionDto[];
}