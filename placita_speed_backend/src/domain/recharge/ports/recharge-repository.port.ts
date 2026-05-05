import { Recharge } from '../recharge';

export interface RechargeRepositoryPort {
    findById(id: string): Promise<Recharge | null>;
    findAll(): Promise<Recharge[]>;
    save(recharge: Recharge): Promise<Recharge>;
    update(recharge: Recharge): Promise<Recharge>;
    delete(id: string): Promise<void>;
}
