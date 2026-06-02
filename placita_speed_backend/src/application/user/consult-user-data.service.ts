import { Injectable } from '@nestjs/common';
import { User } from '@domain/user/user';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class ConsultUserData {
  constructor(private readonly userRepository: UserRepositoryPort) {}
  
  async execute(email: string): Promise<User|null> {
    const user = await this.userRepository.find(email);
    if (!user) {
      throw new Error('Usuario no encontrado');
    }
    return user;
  }
}
