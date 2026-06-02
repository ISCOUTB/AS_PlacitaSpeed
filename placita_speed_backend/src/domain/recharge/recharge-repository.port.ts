import { Injectable } from '@nestjs/common';
import { Recharge } from './recharge';
import { RepositoryPort } from '@domain/repository.port';

@Injectable()
export abstract class RechargeRepositoryPort extends RepositoryPort<Recharge> {
  abstract find(id: string): Promise<Recharge | null>;
  abstract findByUser(email: string): Promise<Recharge[]>;
  abstract delete(id: string): void;
}
