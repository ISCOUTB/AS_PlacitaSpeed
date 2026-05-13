import { Lunch } from './lunch';

/**
 * Puerto de repositorio para Lunch
 * Define el contrato que cualquier adaptador de persistencia debe cumplir
 * Esta interfaz pertenece al dominio y es independiente de TypeORM
 */
export interface LunchRepositoryPort {
  findById(id: number): Promise<Lunch | null>;
  findAll(): Promise<Lunch[]>;
  findAvailable(): Promise<Lunch[]>;
  save(lunch: Lunch): Promise<Lunch>;
  update(lunch: Lunch): Promise<Lunch>;
  delete(id: number): Promise<void>;
}
