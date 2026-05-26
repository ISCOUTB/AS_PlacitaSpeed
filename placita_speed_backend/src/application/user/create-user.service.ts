import { Injectable } from '@nestjs/common';
import { User, UserRole } from '@domain/user/user';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { AuthPort } from '@domain/user/auth.port';

@Injectable()
export class CreateUserService {
  constructor(
    private readonly userRepository: UserRepositoryPort,
    private readonly auth: AuthPort
  ) {}

  async execute(email: string, password: string, role: UserRole): Promise<User> {
    const existing = await this.userRepository.findByEmail(email);
    if (existing) {
      throw new Error('El usuario ya existe');
    }

    const hashed = await this.auth.hashPassword(password);
    const newUser = new User();
    newUser.email = email;
    newUser.password = hashed;
    newUser.role = role;
    newUser.virtual_balance = 0;
    newUser.created_at = new Date();
    newUser.last_access = new Date();

    return this.userRepository.save(newUser);
  }
}
