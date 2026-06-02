import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Recharge } from '@domain/recharge/recharge';
import { RechargeEntity } from '../recharge/recharge.entity';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';

import { UserTypeormRepository } from '../user/user-typeorm.repository';

@Injectable()
export class RechargeTypeormRepository extends RechargeRepositoryPort {
  private repository: Repository<RechargeEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository
  ) {
    super();
    this.repository = this.dataSource.getRepository(RechargeEntity);
  }

  mapToDomain(rechargeEntity: RechargeEntity): Recharge {
    const recharge = new Recharge();
    recharge.id = rechargeEntity.id;
    recharge.value = rechargeEntity.value;
    recharge.state = rechargeEntity.state;
    recharge.started_at = rechargeEntity.started_at;
    recharge.ended_at = rechargeEntity.ended_at;
    recharge.user_email =  rechargeEntity.user.email;
    return recharge;
  }

  async mapToORM(recharge: Recharge, user_email: string): Promise<RechargeEntity> {
    const rechargeEntity = new RechargeEntity();
    rechargeEntity.id = recharge.id;
    rechargeEntity.value = recharge.value;
    rechargeEntity.state = recharge.state;
    rechargeEntity.started_at = recharge.started_at;
    rechargeEntity.ended_at = recharge.ended_at || undefined;
    
    let userEntity = await this.userRepository.findORM(user_email)
    if (!userEntity) {
      throw new Error(`Usuario con email ${user_email} no encontrado`);
    }
    rechargeEntity.user = userEntity;
    return rechargeEntity;
  }

  // Buscar por ID y devolver la entidad TypeORM
    async findORM(id: string): Promise<RechargeEntity | null> {
      return await this.repository.findOne({
        where: { id }
      });
    }

  // Buscar por id
  async find(id: string): Promise<Recharge | null> {
    const entity = await this.findORM(id);
    return entity ? this.mapToDomain(entity) : null;
  }

  // Buscar todos
  async findAll(): Promise<Recharge[]> {
    const entities = await this.repository.find();
    return entities.map(entity => this.mapToDomain(entity));
  }

  // Guardar
  async create(recharge: Recharge): Promise<Recharge> {
    const entity = await this.mapToORM(recharge, recharge.user_email);
    const savedEntity = await this.repository.save(entity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(recharge: Recharge) {
    const entity = await this.mapToORM(recharge, recharge.user_email);
    await this.repository.update({ id: recharge.id }, entity);
  }

  // Borrar por id
  async delete(id: string) {
    await this.repository.delete(id);
  }

  async findByUser(email: string): Promise<Recharge[]> {
    const entities = await this.repository.find({
      where: { user: { email } },
      relations: ['user']
    });
    return entities.map(entity => this.mapToDomain(entity));
  }

}
