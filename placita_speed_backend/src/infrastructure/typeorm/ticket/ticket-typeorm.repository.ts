import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Ticket } from '@domain/ticket/ticket';
import { TicketEntity } from '../ticket/ticket.entity';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

import { UserEntity } from '../user/user.entity';
import { UserTypeormRepository } from '../user/user-typeorm.repository';

import { LunchEntity } from '../lunch/lunch.entity';
import { LunchTypeormRepository } from '../lunch/lunch-typeorm.repository';

@Injectable()
export class TicketTypeormRepository implements TicketRepositoryPort {
  ticketRepository: Repository<TicketEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository,
    private lunchRepository: LunchTypeormRepository
  ) {
    this.ticketRepository = this.dataSource.getRepository(TicketEntity);
  }

  mapToDomain(ticketEntity: TicketEntity): Ticket {
    return new Ticket(
      ticketEntity.id,
      ticketEntity.state,
      ticketEntity.created_at,
      ticketEntity.used_at || null,
      ticketEntity.user.email,
      ticketEntity.lunch.id
    );
  }

  mapToORM(ticket: Ticket, user_email: string, lunch_id: number): TicketEntity {
    const ticketEntity = new TicketEntity();
    ticketEntity.id = ticket.id;
    ticketEntity.state = ticket.state;
    ticketEntity.created_at = ticket.created_at;
    ticketEntity.used_at = ticket.used_at || undefined;

    this.userRepository.findByEmailORM(user_email)
    .then(userEntity => {
      if (!userEntity) {
        throw new Error(`Usuario con email ${user_email} no encontrado`);
      }
      ticketEntity.user = userEntity;
    });

    this.lunchRepository.findByIdORM(lunch_id)
    .then(lunchEntity => {
      if (!lunchEntity) {
        throw new Error(`Usuario con email ${user_email} no encontrado`);
      }
      ticketEntity.lunch = lunchEntity;
    });

    return ticketEntity;
  }

  // Buscar por id
  async findById(id: string): Promise<Ticket | null> {
    return this.ticketRepository.findOne({ where: { id }, relations: ['user', 'lunch'] })
      .then(ticketEntity => ticketEntity ? this.mapToDomain(ticketEntity) : null);
  }

  // Buscar todos
  async findAll(): Promise<Ticket[]> {
    const ticketEntities = await this.ticketRepository.find({ relations: ['user', 'lunch'] });
    return ticketEntities.map(entity => this.mapToDomain(entity))
  }

  // Guardar
  async save(ticket: Ticket, user_email: string, lunch_id: number): Promise<Ticket> {
    const ticketEntity = this.mapToORM(ticket, user_email, lunch_id);
    const savedEntity = await this.ticketRepository.save(ticketEntity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(ticket: Ticket, user_email: string, lunch_id: number): Promise<Ticket> {
    const ticketEntity = this.mapToORM(ticket, user_email, lunch_id);
    const savedEntity = await this.ticketRepository.save(ticketEntity)
    return this.mapToDomain(savedEntity);
  }

  // Borrar por id
  async delete(id: string): Promise<void> {
    return this.ticketRepository.delete(id).then(() => {});
  }
}
