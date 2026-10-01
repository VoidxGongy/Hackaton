import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class CheckinDto {
  @ApiProperty({
    description: 'UUID del qr_token del Área escaneado por el supervisor',
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  })
  @IsString()
  @IsNotEmpty()
  qr_token: string;
}
