import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Recharge } from '@domain/recharge/recharge';
import { RechargeEntity } from '../recharge/recharge.entity';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';

import { UserEntity } from '../user/user.entity';
import { UserTypeormRepository } from '../user/user-typeorm.repository';

@Injectable()
export class RechargeTypeormRepository implements RechargeRepositoryPort {
  private rechargeRepository: Repository<RechargeEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository
  ) {
    this.rechargeRepository = this.dataSource.getRepository(RechargeEntity);
  }

  mapToDomain(rechargeEntity: RechargeEntity): Recharge {
    return new Recharge(
      rechargeEntity.id,
      rechargeEntity.value,
      rechargeEntity.state,
      rechargeEntity.started_at,
      rechargeEntity.ended_at || null,
      rechargeEntity.user.email
    );
  }

  mapToORM(recharge: Recharge, user_email: string): RechargeEntity {
    const rechargeEntity = new RechargeEntity();
    rechargeEntity.id = recharge.id;
    rechargeEntity.value = recharge.value;
    rechargeEntity.state = recharge.state;
    rechargeEntity.started_at = recharge.started_at;
    rechargeEntity.ended_at = recharge.ended_at || undefined;
    
    const promise = this.userRepository.findByEmailORM(user_email);
    promise.then(userEntity => {
      if (!userEntity) {
        throw new Error(`Usuario con email ${user_email} no encontrado`);
      }
      rechargeEntity.user = userEntity; 
    });

    return rechargeEntity;
  }

  // Buscar por id
  async findById(id: string): Promise<Recharge | null> {
    return this.rechargeRepository.findOne({ where: { id }, relations: ['user'] })
      .then(rechargeEntity => rechargeEntity ? this.mapToDomain(rechargeEntity) : null);
  }

  // Buscar todos
  async findAll(): Promise<Recharge[]> {
    const rechargeEntities = await this.rechargeRepository.find({ relations: ['user'] });
    return rechargeEntities.map(entity => this.mapToDomain(entity));
  }

  // Guardar
  async save(recharge: Recharge, user_email: string): Promise<Recharge> {
    const rechargeEntity = this.mapToORM(recharge, user_email);
    const savedEntity = await this.rechargeRepository.save(rechargeEntity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(recharge: Recharge, user_email: string): Promise<Recharge> {
    const rechargeEntity = this.mapToORM(recharge, user_email);
    const savedEntity = await this.rechargeRepository.save(rechargeEntity);
    return this.mapToDomain(savedEntity);
  }

  // Borrar por id
  async delete(id: string): Promise<void> {
    await this.rechargeRepository.delete(id);
  }
}
