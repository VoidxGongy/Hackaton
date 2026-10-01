import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { jwtConstants } from './constants';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtAccessStrategy } from './jwt.strategy';
import { RolesGuard } from './roles.guard';

@Module({
  imports: [
    JwtModule.register({
      secret: jwtConstants.accessSecret,
      signOptions: { expiresIn: jwtConstants.accessExpiresIn } as any,
    }),
  ],
  providers: [AuthService, JwtAccessStrategy, RolesGuard],
  controllers: [AuthController],
  exports: [],
})
export class AuthModule {}
