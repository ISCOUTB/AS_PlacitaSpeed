import { Injectable } from '@nestjs/common';
import { DataSource, MoreThan, Repository } from 'typeorm';

import { Lunch } from '@domain/lunch/lunch';
import { LunchEntity } from '../lunch/lunch.entity';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class LunchTypeormRepository extends LunchRepositoryPort {
  private repository: Repository<LunchEntity>;

  constructor(private dataSource: DataSource) {
    super();
    this.repository = this.dataSource.getRepository(LunchEntity);
  }

  // Convertir clase de Entidad a clase de Dominio
  mapToDomain(lunchEntity: LunchEntity): Lunch {
    const lunch = new Lunch();
    lunch.id = lunchEntity.id;
    lunch.name = lunchEntity.name;
    lunch.description = lunchEntity.description;
    lunch.virtual_price = Number(lunchEntity.virtual_price);
    lunch.stock = lunchEntity.stock;
    return lunch;
  }

  // Convertir clase de Dominio a clase de Entidad
  mapToORM(lunch: Lunch): LunchEntity {
    const lunchEntity = new LunchEntity();
    lunchEntity.id = lunch.id;
    lunchEntity.name = lunch.name;
    lunchEntity.description = lunch.description;
    lunchEntity.virtual_price = lunch.virtual_price;
    lunchEntity.stock = lunch.stock;
    return lunchEntity;
  }

  // Buscar por ID y devolver la entidad TypeORM
  async findORM(id: number): Promise<LunchEntity | null> {
    return await this.repository.findOne({
      where: { id }
    });
  }

  // Buscar por ID y devolver la entidad de dominio
  async find(id: number): Promise<Lunch | null> {
    const entity = await this.findORM(id);
    return entity ? this.mapToDomain(entity) : null;
  }

  // Buscar todos
  async findAll(): Promise<Lunch[]> {
    const entities = await this.repository.find();
    return entities.map(entity => this.mapToDomain(entity));
  }

  // Crear nuevo
  async create(lunch: Lunch): Promise<Lunch> {
    const entity = this.mapToORM(lunch);
    const savedEntity = await this.repository.save(entity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar existente
  async update(lunch: Lunch) {
    const entity = this.mapToORM(lunch);
    await this.repository.update({ id: lunch.id }, entity);
    //return this.mapToDomain(updatedEntity);
  }

  // Borrar
  async delete(id: number) {
    await this.repository.delete({ id });
  }

  // Buscar almuerzos disponibles (stock > 0)
  async findAvailable(): Promise<Lunch[]> {
    const entities = await this.repository.find({
      where: {
        stock: MoreThan(0)
      },
    });

    return entities.map(entity => this.mapToDomain(entity));
  }
}
