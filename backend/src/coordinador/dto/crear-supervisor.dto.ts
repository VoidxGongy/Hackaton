import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, IsOptional, MinLength } from 'class-validator';

export class CrearSupervisorDto {
  @ApiProperty({ example: 'supervisor1@empresa.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ example: 'Juan Pérez' })
  @IsString()
  nombre: string;

  @ApiProperty({ example: '123456789', required: false })
  @IsOptional()
  @IsString()
  numeroIdentificacion?: string;

  @ApiProperty({ example: '3001234567', required: false })
  @IsOptional()
  @IsString()
  telefono?: string;
}
