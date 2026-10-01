import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, IsUUID, Min, Max } from 'class-validator';

export class CrearEvaluacionDto {
  @ApiPropertyOptional({ example: 'visita-uuid' })
  @IsUUID()
  visitaId: string;

  @ApiPropertyOptional({ example: 'cliente-uuid' })
  @IsUUID()
  clienteId: string;

  @ApiPropertyOptional({ example: 4, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  puntuacion?: number;

  @ApiPropertyOptional({ example: 'Visita cumplida según lo acordado', required: false })
  @IsOptional()
  @IsString()
  comentario?: string;
}
