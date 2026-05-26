import { Controller, Get, Post, Patch, Body, Param } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto, UpdateBalanceDto } from './dto/user.dto';

@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get()
  async findAll() {
    return this.usersService.findAll();
  }

  @Get(':email')
  async findOne(@Param('email') email: string) {
    return this.usersService.updateLastAccess(email);
  }

  @Post()
  async create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }

  @Patch(':email/balance')
  async addBalance(@Param('email') email: string, @Body() dto: UpdateBalanceDto) {
    return this.usersService.addBalance(email, dto);
  }
}
