import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class RegistrarDispositivoDto {
  @ApiProperty({ example: 'cHJzaGllbGRlZXRva2VuMTIz' })
  @IsString()
  @IsNotEmpty()
  push_token: string;

  @ApiProperty({ example: 'android' })
  @IsString()
  @IsNotEmpty()
  plataforma: string;
}
