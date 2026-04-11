import { Injectable } from '@nestjs/common';
import { Recharge } from './recharge.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class RechargesService {
    constructor(
        @InjectRepository(Recharge)
        private rechargeRepository: Repository<Recharge>,
    ) {}
}
