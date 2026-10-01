import { Request } from 'express';
import { Rol } from '@prisma/client';
import { AuthenticatedUser } from '../auth/jwt.strategy';

export interface AuthenticatedRequest extends Request {
  user: AuthenticatedUser;
}
