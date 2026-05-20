import { Injectable } from '@nestjs/common';
/**
 * LogoutUser
 *
 * Con JWT stateless el logout se maneja en el cliente eliminando el token.
 * En esta capa de aplicación dejamos el caso de uso preparado para que,
 * si en el futuro se implementa una blacklist de tokens (p.ej. Redis),
 * se pueda inyectar el puerto correspondiente aquí.
 *
 * Por ahora simplemente valida que el usuario exista y retorna confirmación.
 */
import { UserRepositoryPort } from '../../domain/user/user-repository.port';

@Injectable()
export class LogoutUserService {
  constructor(private readonly userRepository: UserRepositoryPort) {}

  async execute(email: string): Promise<{ message: string }> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Usuario no encontrado');
    }
    // Punto de extensión: invalidar token en blacklist si se implementa.
    return { message: 'Sesión cerrada. Por favor elimina el token en el cliente.' };
  }
}
