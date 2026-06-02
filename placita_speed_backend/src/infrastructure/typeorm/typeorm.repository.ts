/*import { RepositoryPort } from "@domain/repository.port";

export class TypeormRepository<Entity> extends RepositoryPort<Entity> {
  private repository: any;
  private mapToDomain: any;

  async findAll(): Promise<Entity[]> {
      const lunchEntities = await this.repository.find();

  // Convertir a lista
  return lunchEntities.map(entity => this.mapToDomain(entity));
  }

  async create(entity: Entity): Promise<Entity> {
    const entity = this.mapToORM(entity);
    const savedEntity = await this.repository.save(entity);
    return this.mapToDomain(savedEntity);
  }
  // Actualizar un almuerzo existente
  async update(lunch: Lunch) {
    const lunchEntity = this.mapToORM(lunch);
    await this.lunchRepository.update({ id: lunch.id }, lunchEntity);
    //return this.mapToDomain(updatedEntity);
  }
}*/