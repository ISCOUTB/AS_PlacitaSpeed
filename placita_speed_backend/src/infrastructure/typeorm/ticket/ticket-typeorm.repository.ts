import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Ticket } from '@domain/ticket/ticket';
import { TicketEntity } from '../ticket/ticket.entity';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

import { User } from '@domain/user/user';
import { UserEntity } from '../user/user.entity';
import { UserTypeormRepository } from '../user/user-typeorm.repository';

import { Lunch } from '@domain/lunch/lunch';
import { LunchEntity } from '../lunch/lunch.entity';
import { LunchTypeormRepository } from '../lunch/lunch-typeorm.repository';

// TODO: Quitar el forwardRef y mejorar la inyección de dependencias para evitar acoplamientos circulares

@Injectable()
export class TicketTypeormRepository implements TicketRepositoryPort {
  ticketRepository: Repository<TicketEntity>;

  constructor(
    private dataSource: DataSource,
    @Inject(forwardRef(() => UserTypeormRepository)) private userRepository: UserTypeormRepository,
    @Inject(forwardRef(() => LunchTypeormRepository)) private lunchRepository: LunchTypeormRepository
  ) {
    this.ticketRepository = this.dataSource.getRepository(TicketEntity);
  }

  mapToDomain(ticketEntity: TicketEntity): Ticket {
    let user: User;
    if (ticketEntity.user) {
      user = this.userRepository.mapToDomain(ticketEntity.user);
    } else {
      user = null as any;
    }

    let lunch: Lunch;
    if (ticketEntity.lunch) {
      lunch = this.lunchRepository.mapToDomain(ticketEntity.lunch);
    } else {
      lunch = null as any;
    }

    return new Ticket(
      ticketEntity.id,
      ticketEntity.state,
      ticketEntity.created_at,
      ticketEntity.used_at || null,
      user,
      lunch
    );
  }

  mapToORM(ticket: Ticket): TicketEntity {
    let userEnt: UserEntity = this.userRepository.mapToORM(ticket.user);
    let lunchEnt: LunchEntity = this.lunchRepository.mapToORM(ticket.lunch);
    const ticketEntity = new TicketEntity();
    ticketEntity.id = ticket.id;
    ticketEntity.state = ticket.state;
    ticketEntity.created_at = ticket.created_at;
    ticketEntity.used_at = ticket.used_at || undefined;
    ticketEntity.user = userEnt;
    ticketEntity.lunch = lunchEnt;
    return ticketEntity;
  }

  // Implementation for ticket repository
  async findById(id: string): Promise<Ticket | null> {
    return this.ticketRepository.findOne({ where: { id }, relations: ['user', 'lunch'] })
      .then(ticketEntity => ticketEntity ? this.mapToDomain(ticketEntity) : null);
  }

  async findAll(): Promise<Ticket[]> {
    return this.ticketRepository.find({ relations: ['user', 'lunch'] })
      .then(entities => entities.map((entity) => this.mapToDomain(entity)));
  }

  async save(ticket: Ticket): Promise<Ticket> {
    const ticketEntity = this.mapToORM(ticket);
    return this.ticketRepository.save(ticketEntity)
      .then(savedEntity => this.mapToDomain(savedEntity));
  }

  async update(ticket: Ticket): Promise<Ticket> {
    const ticketEntity = this.mapToORM(ticket);
    return this.ticketRepository.save(ticketEntity)
      .then(updatedEntity => this.mapToDomain(updatedEntity));
  }

  async delete(id: string): Promise<void> {
    return this.ticketRepository.delete(id).then(() => {});
  }
}
