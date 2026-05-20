import { Injectable } from '@nestjs/common';
import { Lunch } from '@domain/lunch/lunch';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';
 // Este adaptador es solo para pruebas, no se conecta a una base de datos real
@Injectable()
export class LunchMemoryAdapter extends LunchRepositoryPort {
  private lunches: Lunch[] = [];

  async findById(id: number): Promise<Lunch | null> {
    return this.lunches.find(lunch => lunch.id === id) || null;
  }

  async findAll(): Promise<Lunch[]> {
    return this.lunches;
  }

  async findAvailable(): Promise<Lunch[]> {
    return this.lunches.filter(lunch => lunch.stock > 0);
  }

  async save(lunch: Lunch): Promise<Lunch> {
    this.lunches.push(lunch);
    return lunch;
  }

  update(lunch: Lunch): void {
    const index = this.lunches.findIndex(l => l.id === lunch.id);
    if (index !== -1) {
      this.lunches[index] = lunch;
    }
  }

  delete(id: number): void {
    this.lunches = this.lunches.filter(lunch => lunch.id !== id);
  }
}