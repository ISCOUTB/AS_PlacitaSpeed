import { Injectable } from '@nestjs/common';
import { Recharge } from './recharge';

@Injectable()
export abstract class RechargeRepositoryPort {
    abstract findById(id: string): Promise<Recharge | null>;
    abstract findAll(): Promise<Recharge[]>;
    abstract save(recharge: Recharge): Promise<Recharge>;
    abstract update(recharge: Recharge): void;
    abstract delete(id: string): void;
    abstract findRechargesByUser(email: string): Promise<Recharge[]>;
}
