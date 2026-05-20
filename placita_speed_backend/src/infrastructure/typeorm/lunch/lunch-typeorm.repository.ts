import { Injectable } from '@nestjs/common';
import { DataSource, MoreThan, Repository } from 'typeorm';

import { Lunch } from '@domain/lunch/lunch';
import { LunchEntity } from '../lunch/lunch.entity';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class LunchTypeormRepository extends LunchRepositoryPort {
  private lunchRepository: Repository<LunchEntity>;

  constructor(private dataSource: DataSource) {
    super();
    this.lunchRepository = this.dataSource.getRepository(LunchEntity);
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

  // Buscar un almuerzo por ID y devolver la entidad TypeORM
  async findByIdORM(id: number): Promise<LunchEntity | null> {
    const lunchEntity = await this.lunchRepository.findOne({
      where: { id }
    });

    if (!lunchEntity) {
      return null;
    }

    return lunchEntity;
  }

  // Buscar un almuerzo por ID y devolver la entidad de dominio
  async findById(id: number): Promise<Lunch | null> {
    const lunchEntity = await this.lunchRepository.findOne({
      where: { id },
    });

    if (!lunchEntity) {
      return null;
    }

    return this.mapToDomain(lunchEntity);
  }

  // Buscar todos los almuerzos
  async findAll(): Promise<Lunch[]> {
    const lunchEntities = await this.lunchRepository.find();

    // Convertir a lista
    return lunchEntities.map(entity => this.mapToDomain(entity));
  }

  // Buscar almuerzos disponibles (stock > 0)
  async findAvailable(): Promise<Lunch[]> {
    const lunchEntities = await this.lunchRepository.find({
      where: {
        stock: MoreThan(0)
      },
    });

    return lunchEntities.map(entity => this.mapToDomain(entity));
  }

  // Guardar un nuevo almuerzo
  async save(lunch: Lunch): Promise<Lunch> {
    const lunchEntity = this.mapToORM(lunch);
    const savedEntity = await this.lunchRepository.save(lunchEntity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar un almuerzo existente
  async update(lunch: Lunch) {
    const lunchEntity = this.mapToORM(lunch);
    await this.lunchRepository.update({ id: lunch.id }, lunchEntity);
    //return this.mapToDomain(updatedEntity);
  }

  // Borrar un almuerzo por ID
  async delete(id: number) {
    await this.lunchRepository.delete({ id });
  }
}
