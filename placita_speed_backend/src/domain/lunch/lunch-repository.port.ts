import { Injectable } from '@nestjs/common';
import { Lunch } from './lunch';
import { RepositoryPort } from '@domain/repository.port';

@Injectable()
export abstract class LunchRepositoryPort extends RepositoryPort<Lunch> {
  abstract find(id: number): Promise<Lunch | null>;
  abstract findAvailable(): Promise<Lunch[]>;
  abstract delete(id: number): void;
}
