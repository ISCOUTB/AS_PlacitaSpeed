import { RechargeTypeormRepository } from '@infrastructure/database/typeorm/recharge-typeorm.repository';
import { Controller, Get } from '@nestjs/common';

@Controller('recharge')
export class RechargeController {
    constructor(private rechargeRepository: RechargeTypeormRepository) {}

    @Get()
    async findAll() {
        return await this.rechargeRepository.findAll();
    }
}
