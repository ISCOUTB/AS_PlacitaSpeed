import { Injectable } from '@nestjs/common';
import { Lunch } from '@domain/lunch/lunch';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class ConsultLunches {
  constructor(private readonly lunchRepository: LunchRepositoryPort) {}

  async execute(): Promise<Lunch[]> {
    return this.lunchRepository.findAll();
  }
}
