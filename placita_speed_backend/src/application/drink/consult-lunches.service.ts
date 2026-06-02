import { Injectable } from '@nestjs/common';
import { Drink } from '@domain/drink/drink';
import { DrinkRepositoryPort } from '@domain/drink/drink-repository.port';

@Injectable()
export class ConsultDrinks {
  constructor(private readonly drinkRepository: DrinkRepositoryPort) {}

  async execute(): Promise<Drink[]> {
    return this.drinkRepository.findAll();
  }
}
