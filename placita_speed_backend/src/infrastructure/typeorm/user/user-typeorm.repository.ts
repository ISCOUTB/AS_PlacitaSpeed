import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { User } from '@domain/user/user';
import { UserEntity } from '../user/user.entity';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class UserTypeormRepository extends UserRepositoryPort {
  private repository: Repository<UserEntity>;

  constructor(private dataSource: DataSource) {
    super();
    this.repository = this.dataSource.getRepository(UserEntity);
  }

  mapToDomain(userEntity: UserEntity): User {
    const user = new User();
    user.email = userEntity.email;
    user.password = userEntity.password;
    user.role = userEntity.role;
    user.virtual_balance = Number(userEntity.virtual_balance);
    user.created_at = userEntity.created_at;
    user.last_access = userEntity.last_access;
    return user;
  }

  mapToORM(user: User): UserEntity {
    const userEntity = new UserEntity();
    userEntity.email = user.email;
    userEntity.password = user.password;
    userEntity.role = user.role;
    userEntity.virtual_balance = user.virtual_balance;
    userEntity.created_at = user.created_at;
    userEntity.last_access = user.last_access;
    return userEntity;
  }

  // Buscar por email y devolver ORM
  async findORM(email: string): Promise<UserEntity | null> {
    return await this.repository.findOne({
      where: { email }
    });
  }

  // Buscar por email
  async find(email: string): Promise<User | null> {
    const entity = await this.findORM(email);
    return entity ? this.mapToDomain(entity) : null;
  }

  // Buscar todos
  async findAll(): Promise<User[]> {
    const userEntities = await this.repository.find();
    return userEntities.map(userEntity => this.mapToDomain(userEntity));
  }

  // Guardar nuevo
  async create(user: User): Promise<User> {
    const entity = this.mapToORM(user);
    const savedUser = await this.repository.save(entity);
    return this.mapToDomain(savedUser);
  }

  // Actualizar existente
  async update(user: User, password: string = '') {
    const entity = this.mapToORM(user);
    if (password) {
      entity.password = password;
    }
    await this.repository.update({ email: user.email }, entity);
  }

  // Eliminar por email
  async delete(email: string) {
    await this.repository.delete({ email });
  }

  // Actualizar último acceso
  async updateLastAccess(email: string) {
    await this.repository.update({ email }, { last_access: new Date() });
  }
    
}
