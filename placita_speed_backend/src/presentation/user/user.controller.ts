import { UserTypeormRepository } from '@infrastructure/database/typeorm/user-typeorm.repository';
import { Controller, Get } from '@nestjs/common';

@Controller('user')
export class UserController {
    constructor(private userRepository: UserTypeormRepository) {}

    @Get()
    async findAll() {
        return await this.userRepository.findAll();
    }
}
