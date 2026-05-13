import { Recharge } from './recharge';

export interface RechargeRepositoryPort {
    findById(id: string): Promise<Recharge | null>;
    findAll(): Promise<Recharge[]>;
    save(recharge: Recharge, user_email: string): Promise<Recharge>;
    update(recharge: Recharge, user_email: string): Promise<Recharge>;
    delete(id: string): Promise<void>;
}
