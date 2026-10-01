import { IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AsignarSupervisorAreaDto {
  @ApiProperty({ example: 'supervisor-uuid' })
  @IsUUID()
  supervisorId: string;

  @ApiProperty({ example: 'area-uuid' })
  @IsUUID()
  areaId: string;
}
