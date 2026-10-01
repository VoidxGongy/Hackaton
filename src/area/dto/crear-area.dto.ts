import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsUUID } from 'class-validator';

export class CrearAreaDto {
  @ApiProperty({ example: 'Edificio Central' })
  @IsString()
  nombre: string;

  @ApiProperty({ example: 'Área de aseo de baños', required: false })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiProperty({ example: 'Calle 100 #50-30', required: false })
  @IsOptional()
  @IsString()
  direccion?: string;

  @ApiProperty({ example: 'cliente-uuid', required: false })
  @IsOptional()
  @IsUUID()
  clienteId?: string;
}
