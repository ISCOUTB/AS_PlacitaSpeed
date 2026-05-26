import { Injectable } from '@nestjs/common';
import { Lunch } from './lunch';

/**
 * Puerto de repositorio para Lunch
 * Define el contrato que cualquier adaptador de persistencia debe cumplir
 * Esta interfaz pertenece al dominio y es independiente de TypeORM
 */
@Injectable()
export abstract class LunchRepositoryPort {
  abstract findById(id: number): Promise<Lunch | null>;
  abstract findAll(): Promise<Lunch[]>;
  abstract findAvailable(): Promise<Lunch[]>;
  abstract save(lunch: Lunch): Promise<Lunch>;
  abstract update(lunch: Lunch): void;
  abstract delete(id: number): void;
}
