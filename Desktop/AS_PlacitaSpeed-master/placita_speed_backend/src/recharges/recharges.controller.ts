import { Controller, Get, Post, Patch, Body, Param } from '@nestjs/common';
import { RechargesService } from './recharges.service';
import { CreateRechargeDto } from './dto/recharge.dto';

@Controller('recharges')
export class RechargesController {
    constructor(private rechargesService: RechargesService) {}

    @Get()
    async getRecharges() {
        return this.rechargesService.getRecharges();
    }

    @Get('user/:email')
    async getRechargesByUser(@Param('email') email: string) {
        return this.rechargesService.getRechargesByUser(email);
    }

    @Get(':id')
    async getRecharge(@Param('id') id: string) {
        return this.rechargesService.getRecharge(id);
    }

    @Post()
    async createRecharge(@Body() dto: CreateRechargeDto) {
        return this.rechargesService.createRecharge(dto);
    }

    @Patch(':id/complete')
    async completeRecharge(@Param('id') id: string) {
        return this.rechargesService.completeRecharge(id);
    }

    @Patch(':id/fail')
    async failRecharge(@Param('id') id: string) {
        return this.rechargesService.failRecharge(id);
    }
}
