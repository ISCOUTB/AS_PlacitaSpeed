import { Injectable } from '@nestjs/common';
import { Drink } from './drink';
import { RepositoryPort } from '@domain/repository.port';

@Injectable()
export abstract class DrinkRepositoryPort extends RepositoryPort<Drink> {
  abstract find(id: number): Promise<Drink | null>;
  abstract findAvailable(): Promise<Drink[]>;
  abstract delete(id: number): void;
}