import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { EstadoTarea } from '@prisma/client';

export class MarcarTareaDto {
  @ApiProperty({ enum: EstadoTarea, example: EstadoTarea.CUMPLIDA })
  @IsEnum(EstadoTarea)
  estado: EstadoTarea;
}
