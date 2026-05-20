import { Injectable } from '@nestjs/common';
import { Recharge } from '@domain/recharge/recharge';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';

@Injectable()
export class ConsultRechargesByUserService {
  constructor(private readonly rechargeRepository: RechargeRepositoryPort) {}

  async execute(email: string): Promise<Recharge[]> {
    return this.rechargeRepository.findRechargesByUser(email);
  }
}