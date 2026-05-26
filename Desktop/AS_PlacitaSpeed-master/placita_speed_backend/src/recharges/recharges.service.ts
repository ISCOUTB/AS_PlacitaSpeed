import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { Recharge, RechargeState } from './recharge.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { UsersService } from 'src/users/users.service';
import { CreateRechargeDto } from './dto/recharge.dto';

@Injectable()
export class RechargesService {
    constructor(
        @InjectRepository(Recharge)
        private rechargeRepository: Repository<Recharge>,
        private usersService: UsersService,
    ) {}

    async getRecharges(): Promise<Recharge[]> {
        return this.rechargeRepository.find({ relations: ['user'] });
    }

    async getRechargesByUser(email: string): Promise<Recharge[]> {
        return this.rechargeRepository.find({
            where: { user: { email } },
            order: { started_at: 'DESC' },
        });
    }

    async getRecharge(id: string): Promise<Recharge> {
        const recharge = await this.rechargeRepository.findOne({
            where: { id },
            relations: ['user'],
        });
        if (!recharge) throw new HttpException('Recharge not found', HttpStatus.NOT_FOUND);
        return recharge;
    }

    async createRecharge(dto: CreateRechargeDto): Promise<Recharge> {
        const user = await this.usersService.findOne(dto.userEmail);
        const recharge = this.rechargeRepository.create({ user, value: dto.value });
        return this.rechargeRepository.save(recharge);
    }

    async completeRecharge(id: string): Promise<Recharge> {
        const recharge = await this.getRecharge(id);
        if (recharge.state !== RechargeState.PENDING) {
            throw new HttpException('Recharge is not pending', HttpStatus.BAD_REQUEST);
        }
        await this.rechargeRepository.update({ id }, {
            state: RechargeState.SUCCESS,
            ended_at: new Date(),
        });
        await this.usersService.addBalance(recharge.user.email, { value: Number(recharge.value) });
        return this.getRecharge(id);
    }

    async failRecharge(id: string): Promise<Recharge> {
        const recharge = await this.getRecharge(id);
        if (recharge.state !== RechargeState.PENDING) {
            throw new HttpException('Recharge is not pending', HttpStatus.BAD_REQUEST);
        }
        await this.rechargeRepository.update({ id }, {
            state: RechargeState.FAILED,
            ended_at: new Date(),
        });
        return this.getRecharge(id);
    }
}
