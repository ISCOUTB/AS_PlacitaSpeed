import { Injectable } from '@nestjs/common';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { AuthPort } from '@domain/user/auth.port';

@Injectable()
export class AutenticateUserService {
  constructor(
    private readonly userRepository: UserRepositoryPort,
    private readonly auth: AuthPort,
  ) {}

  /**
   * Valida email y contraseña, actualiza last_access y retorna un JWT.
   */
  async execute(email: string, password: string): Promise<string> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Credenciales inválidas');
    }

    if (!user.password) {
      throw new Error('Usuario sin contraseña');
    }
    const valid = await this.auth.comparePassword(password, user.password);
    if (!valid) {
      throw new Error('Credenciales inválidas');
    }

    await this.userRepository.updateLastAccess(email);

    const token = this.auth.generateToken({ email: user.email, role: user.role });
    return token;
  }
}
