import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { User } from '@domain/user/user';
import { UserEntity } from '../user/user.entity';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class UserTypeormRepository implements UserRepositoryPort {
    private userRepository: Repository<UserEntity>;

    constructor(private dataSource: DataSource) {
        this.userRepository = this.dataSource.getRepository(UserEntity);
    }

    mapToDomain(userEntity: UserEntity): User {
        return new User(
            userEntity.email,
            userEntity.role,
            Number(userEntity.virtual_balance), // TypeORM puede devolver Decimal, convertir a number
            userEntity.created_at,
            userEntity.last_access,
        );
    }

    mapToORM(user: User): UserEntity {
        const userEntity = new UserEntity();
        userEntity.email = user.email;
        userEntity.role = user.role;
        userEntity.virtual_balance = user.virtual_balance;
        userEntity.created_at = user.created_at;
        userEntity.last_access = user.last_access;
        return userEntity;
    }

    async findByEmailORM(email: string): Promise<UserEntity | null> {
        const userEntity = await this.userRepository.findOne({
            where: { email }
        });

        if (!userEntity) {
            return null;
        }

        return userEntity;
    }

    // Buscar un usuario por email
    async findByEmail(email: string): Promise<User | null> {
        return this.userRepository.findOne({ where: { email }})
            .then(userEntity => userEntity ? this.mapToDomain(userEntity) : null);
    }

    // Buscar todos los usuarios
    async findAll(): Promise<User[]> {
        const userEntities = await this.userRepository.find();
        return userEntities.map(userEntity => this.mapToDomain(userEntity));
    }

    // Guardar un nuevo usuario
    async save(user: User): Promise<User> {
        const userEntity = this.mapToORM(user);
        const savedUser = await this.userRepository.save(userEntity);
        return this.mapToDomain(savedUser);
    }

    // Actualizar un usuario existente
    async update(user: User): Promise<User> {
        const userEntity = this.mapToORM(user);
        const updatedUser = await this.userRepository.save(userEntity);
        return this.mapToDomain(updatedUser);
    }

    // Eliminar un usuario por email
    async delete(email: string): Promise<void> {
        await this.userRepository.delete({ email });
    }
}
