import { LunchTypeormRepository } from '@infrastructure/database/typeorm/lunch-typeorm.repository';
import { Controller, Get } from '@nestjs/common';

@Controller('lunch')
export class LunchController {
    constructor(private lunchRepository: LunchTypeormRepository) {}
    
    @Get()
    async findAll() {
        return await this.lunchRepository.findAll();
    }

}
