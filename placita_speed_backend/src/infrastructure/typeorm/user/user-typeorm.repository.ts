import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { User } from '@domain/user/user';
import { UserEntity } from '../user/user.entity';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

import { Ticket } from '@domain/ticket/ticket';
import { TicketEntity } from '../ticket/ticket.entity';
import { TicketTypeormRepository } from '../ticket/ticket-typeorm.repository';

import { Recharge } from '@domain/recharge/recharge';
import { RechargeEntity } from '../recharge/recharge.entity';
import { RechargeTypeormRepository } from '../recharge/recharge-typeorm.repository';

// TODO: Quitar el forwardRef y mejorar la inyección de dependencias para evitar acoplamientos circulares

@Injectable()
export class UserTypeormRepository implements UserRepositoryPort {
    private userRepository: Repository<UserEntity>;

    constructor(
        private dataSource: DataSource,
        @Inject(forwardRef(() => TicketTypeormRepository)) private ticketRepository: TicketTypeormRepository,
        @Inject(forwardRef(() => RechargeTypeormRepository)) private rechargeRepository: RechargeTypeormRepository
    ) {
        this.userRepository = this.dataSource.getRepository(UserEntity);
    }

    mapToDomain(userEntity: UserEntity): User {
        let ticketlist: Ticket[];
        if (userEntity.tickets) {
            ticketlist = userEntity.tickets.map(ticket => this.ticketRepository.mapToDomain(ticket));
        } else {
            ticketlist = [];
        }

        let rechargelist: Recharge[];
        if (userEntity.recharges) {
            rechargelist = userEntity.recharges.map(recharge => this.rechargeRepository.mapToDomain(recharge));
        } else {
            rechargelist = [];
        }

        return new User(
            userEntity.email,
            userEntity.role,
            Number(userEntity.virtual_balance), // TypeORM puede devolver Decimal, convertir a number
            userEntity.created_at,
            userEntity.last_access,
            ticketlist,
            rechargelist
        );
    }

    mapToORM(user: User): UserEntity {
        let ticketEntlist: TicketEntity[];
        if (user.tickets) {
            ticketEntlist = user.tickets.map(ticket => this.ticketRepository.mapToORM(ticket));
        } else {
            ticketEntlist = [];
        }

        let rechargeEntlist: RechargeEntity[];
        if (user.recharges) {
            rechargeEntlist = user.recharges.map(recharge => this.rechargeRepository.mapToORM(recharge));
        } else {
            rechargeEntlist = [];
        }

        const userEntity = new UserEntity();
        userEntity.email = user.email;
        userEntity.role = user.role;
        userEntity.virtual_balance = user.virtual_balance;
        userEntity.created_at = user.created_at;
        userEntity.last_access = user.last_access;
        userEntity.tickets = ticketEntlist;
        userEntity.recharges = rechargeEntlist;
        return userEntity;
    }

    /**
     * Buscar un usuario por email
     */
    async findById(email: string): Promise<User | null> {
        const userEntity = await this.userRepository.findOne({
            where: { email },
            relations: ['tickets', 'recharges'],
        });

        if (!userEntity) {
            return null;
        }

        return this.mapToDomain(userEntity);
    }

    /**
     * Buscar todos los usuarios
     */
    async findAll(): Promise<User[]> {
        const userEntities = await this.userRepository.find({ relations: ['tickets', 'recharges'] });
        return userEntities.map(userEntity => this.mapToDomain(userEntity));
    }

    /**
     * Guardar un nuevo usuario
     */
    async save(user: User): Promise<User> {
        const userEntity = this.mapToORM(user);
        const savedUser = await this.userRepository.save(userEntity);
        return this.mapToDomain(savedUser);
    }

    /**
     * Actualizar un usuario existente
     */
    async update(user: User): Promise<User> {
        const userEntity = this.mapToORM(user);
        const updatedUser = await this.userRepository.save(userEntity);
        return this.mapToDomain(updatedUser);
    }

    /**
     * Eliminar un usuario por email
     */
    async delete(email: string): Promise<void> {
        await this.userRepository.delete({ email });
    }
}
