import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { EstadoNovedad } from '@prisma/client';

export class CambiarEstadoNovedadDto {
  @ApiProperty({ enum: EstadoNovedad, example: EstadoNovedad.EN_REVISION })
  @IsEnum(EstadoNovedad)
  estado: EstadoNovedad;
}
