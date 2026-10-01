import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { Public } from './public.decorator';
import { AuthenticatedRequest } from '../shared/authenticated-request';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Public()
  @Post('login')
  async login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @ApiBearerAuth()
  @Post('refresh')
  async refresh(@Body('refreshToken') refreshToken: string) {
    return this.auth.refresh(refreshToken);
  }

  @ApiBearerAuth()
  @Post('logout')
  async logout(@Body('refreshToken') refreshToken: string) {
    return this.auth.logout(refreshToken);
  }

  @ApiBearerAuth()
  @Get('me')
  getProfile(@Request() req: AuthenticatedRequest) {
    return req.user;
  }
}
