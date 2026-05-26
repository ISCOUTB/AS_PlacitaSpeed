import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { User } from './user.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateUserDto, UpdateBalanceDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async findOne(email: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { email } });
    if (!user) throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    return user;
  }

  async create(user: CreateUserDto): Promise<User> {
    const exists = await this.usersRepository.findOne({ where: { email: user.email } });
    if (exists) throw new HttpException('User already exists', HttpStatus.CONFLICT);
    return this.usersRepository.save(user);
  }

  async updateLastAccess(email: string): Promise<User> {
    await this.findOne(email);
    await this.usersRepository.update({ email }, { last_access: new Date() });
    return this.findOne(email);
  }

  async addBalance(email: string, dto: UpdateBalanceDto): Promise<User> {
    const user = await this.findOne(email);
    const newBalance = Number(user.virtual_balance) + dto.value;
    await this.usersRepository.update({ email }, { virtual_balance: newBalance });
    return this.findOne(email);
  }

  async deductBalance(email: string, amount: number): Promise<void> {
    const user = await this.findOne(email);
    if (Number(user.virtual_balance) < amount) {
      throw new HttpException('Insufficient balance', HttpStatus.BAD_REQUEST);
    }
    const newBalance = Number(user.virtual_balance) - amount;
    await this.usersRepository.update({ email }, { virtual_balance: newBalance });
  }
}
