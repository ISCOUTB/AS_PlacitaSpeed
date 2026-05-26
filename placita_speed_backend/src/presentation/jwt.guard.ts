import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { BcryptJwtAuthAdapter } from '@infrastructure/auth/bcrypt-jwt-auth.adapter';

@Injectable()
export class JwtGuard implements CanActivate {
  constructor(private readonly authAdapter: BcryptJwtAuthAdapter) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader: string | undefined = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Token no proporcionado');
    }

    const token = authHeader.slice(7);
    const payload = this.authAdapter.verifyToken(token);

    if (!payload) {
      throw new UnauthorizedException('Token inválido o expirado');
    }

    request.user = payload;
    return true;
  }
}
