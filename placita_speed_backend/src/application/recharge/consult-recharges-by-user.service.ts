import { Injectable } from '@nestjs/common';
import { Recharge } from '@domain/recharge/recharge';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';

@Injectable()
export class ConsultRechargesByUser {
  constructor(private readonly rechargeRepository: RechargeRepositoryPort) {}

  async execute(email: string): Promise<Recharge[]> {
    return this.rechargeRepository.findByUser(email);
  }
}