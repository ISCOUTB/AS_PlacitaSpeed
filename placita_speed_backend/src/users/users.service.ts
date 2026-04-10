import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { User } from './user.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateUserDto } from './dto/user.dto';
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // Listar todos los usuarios. No sería necesario en producción
  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  // Buscar un solo usuario
  async findOne(email: string): Promise<User|null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  // Crear usuario mediante su email
  async create(user: CreateUserDto): Promise<User> {
    if (await this.findOne(user.email)) {
      throw new HttpException('User already exists', HttpStatus.CONFLICT);
    }
    return this.usersRepository.save(user);
  }

  // Actualizar la fecha y hora de último acceso
  async updateLastAccess(email: string): Promise<void> {
    await this.usersRepository.update({ email }, { last_access: new Date() });
  }
}