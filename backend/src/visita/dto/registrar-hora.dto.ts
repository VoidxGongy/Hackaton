import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsDateString } from 'class-validator';

export class RegistrarHoraDto {
  @ApiPropertyOptional({
    description: 'ISO 8601. Si no se envía, el backend usa la hora actual.',
    example: '2026-10-10T09:05:00.000Z',
  })
  @IsOptional()
  @IsDateString()
  hora?: string;
}
