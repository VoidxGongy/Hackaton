import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEmail } from 'class-validator';

export class CrearClienteDto {
  @ApiPropertyOptional({ example: 'Empresa Aseo S.A.S.' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ example: 'contacto@cliente.com', required: false })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '3001234567', required: false })
  @IsOptional()
  @IsString()
  telefono?: string;

  @ApiPropertyOptional({ example: 'Calle 100 #50-30', required: false })
  @IsOptional()
  @IsString()
  direccion?: string;
}
