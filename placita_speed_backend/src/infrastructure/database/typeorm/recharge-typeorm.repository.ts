import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Recharge } from '@domain/recharge/recharge';
import { RechargeEntity } from './entities/recharge.entity';
import { RechargeRepositoryPort } from '@domain/recharge/ports/recharge-repository.port';

import { User } from '@domain/user/user';
import { UserEntity } from './entities/user.entity';
import { UserTypeormRepository } from './user-typeorm.repository';

// TODO: Quitar el forwardRef y mejorar la inyección de dependencias para evitar acoplamientos circulares

@Injectable()
export class RechargeTypeormRepository implements RechargeRepositoryPort {
  private rechargeRepository: Repository<RechargeEntity>;

  constructor(
    private dataSource: DataSource,
    @Inject(forwardRef(() => UserTypeormRepository)) private userRepository: UserTypeormRepository
  ) {
    this.rechargeRepository = this.dataSource.getRepository(RechargeEntity);
  }

  mapToDomain(rechargeEntity: RechargeEntity): Recharge {
    let user: User;
    if (rechargeEntity.user) {
      user = this.userRepository.mapToDomain(rechargeEntity.user);
    } else {
      user = null as any;
    }
    return new Recharge(
      rechargeEntity.id,
      rechargeEntity.value,
      rechargeEntity.state,
      rechargeEntity.started_at,
      rechargeEntity.ended_at || null,
      user
    );
  }

  mapToORM(recharge: Recharge): RechargeEntity {
    let userEnt: UserEntity = this.userRepository.mapToORM(recharge.user);
    const rechargeEntity = new RechargeEntity();
    rechargeEntity.id = recharge.id;
    rechargeEntity.value = recharge.value;
    rechargeEntity.state = recharge.state;
    rechargeEntity.started_at = recharge.started_at;
    rechargeEntity.ended_at = recharge.ended_at || undefined;
    rechargeEntity.user = userEnt;
    return rechargeEntity;
  }

  // Implementación de métodos del repositorio de recargas
  async findById(id: string): Promise<Recharge | null> {
    return this.rechargeRepository.findOne({ where: { id }, relations: ['user'] })
      .then(rechargeEntity => rechargeEntity ? this.mapToDomain(rechargeEntity) : null);
  }

  async findAll(): Promise<Recharge[]> {
    const rechargeEntities = await this.rechargeRepository.find({ relations: ['user'] });
    return rechargeEntities.map(entity => this.mapToDomain(entity));
  }

  async save(recharge: Recharge): Promise<Recharge> {
    const rechargeEntity = this.mapToORM(recharge);
    const savedEntity = await this.rechargeRepository.save(rechargeEntity);
    return this.mapToDomain(savedEntity);
  }

  async update(recharge: Recharge): Promise<Recharge> {
    const rechargeEntity = this.mapToORM(recharge);
    await this.rechargeRepository.save(rechargeEntity);
    return this.mapToDomain(rechargeEntity);
  }

  async delete(id: string): Promise<void> {
    await this.rechargeRepository.delete(id);
  }
}
