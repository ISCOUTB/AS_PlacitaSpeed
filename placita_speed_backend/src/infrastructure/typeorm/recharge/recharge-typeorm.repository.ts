import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Recharge } from '@domain/recharge/recharge';
import { RechargeEntity } from '../recharge/recharge.entity';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';

import { UserEntity } from '../user/user.entity';
import { UserTypeormRepository } from '../user/user-typeorm.repository';

@Injectable()
export class RechargeTypeormRepository extends RechargeRepositoryPort {
  private rechargeRepository: Repository<RechargeEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository
  ) {
    super();
    this.rechargeRepository = this.dataSource.getRepository(RechargeEntity);
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
    
    let userEntity = await this.userRepository.findByEmailORM(user_email)
    if (!userEntity) {
      throw new Error(`Usuario con email ${user_email} no encontrado`);
    }
    rechargeEntity.user = userEntity;

    /*
    const promise = this.userRepository.findByEmailORM(user_email);
    promise.then(userEntity => {
      if (!userEntity) {
        throw new Error(`Usuario con email ${user_email} no encontrado`);
      }
      rechargeEntity.user = userEntity; 
    });*/

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
  async save(recharge: Recharge): Promise<Recharge> {
    const rechargeEntity = await this.mapToORM(recharge, recharge.user_email);
    const savedEntity = await this.rechargeRepository.save(rechargeEntity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(recharge: Recharge) {
    const rechargeEntity = await this.mapToORM(recharge, recharge.user_email);
    const savedEntity = await this.rechargeRepository.update({ id: recharge.id }, rechargeEntity);
    //return this.mapToDomain(savedEntity);
  }

  // Borrar por id
  async delete(id: string) {
    await this.rechargeRepository.delete(id);
  }

  async findRechargesByUser(email: string): Promise<Recharge[]> {
    const rechargeEntities = await this.rechargeRepository.find({
      where: { user: { email } },
      relations: ['user']
    });
    return rechargeEntities.map(entity => this.mapToDomain(entity));
  }

}
