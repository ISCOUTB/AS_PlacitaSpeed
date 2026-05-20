import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';

import { Ticket, TicketState } from '@domain/ticket/ticket';
import { TicketEntity } from '../ticket/ticket.entity';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

import { UserEntity } from '../user/user.entity';
import { UserTypeormRepository } from '../user/user-typeorm.repository';

import { LunchEntity } from '../lunch/lunch.entity';
import { LunchTypeormRepository } from '../lunch/lunch-typeorm.repository';

@Injectable()
export class TicketTypeormRepository extends TicketRepositoryPort {
  ticketRepository: Repository<TicketEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository,
    private lunchRepository: LunchTypeormRepository
  ) {
    super();
    this.ticketRepository = this.dataSource.getRepository(TicketEntity);
  }

  mapToDomain(ticketEntity: TicketEntity): Ticket {
    const ticket = new Ticket();
    ticket.id = ticketEntity.id;
    ticket.user_email = ticketEntity.user.email;
    ticket.lunch_id = ticketEntity.lunch.id;
    ticket.state = ticketEntity.state;
    ticket.created_at = ticketEntity.created_at;
    ticket.used_at = ticketEntity.used_at;
    return ticket;
  }

  async mapToORM(ticket: Ticket, user_email: string, lunch_id: number): Promise<TicketEntity> {
    const ticketEntity = new TicketEntity();
    ticketEntity.id = ticket.id;
    ticketEntity.state = ticket.state;
    ticketEntity.created_at = ticket.created_at;
    ticketEntity.used_at = ticket.used_at || undefined;

    let userEntity: UserEntity | null = await this.userRepository.findByEmailORM(user_email);
    if (!userEntity) {
      throw new Error(`Usuario con email ${user_email} no encontrado`);
    }
    ticketEntity.user = userEntity;

    let lunchEntity: LunchEntity | null = await this.lunchRepository.findByIdORM(lunch_id);
    if (!lunchEntity) {
      throw new Error(`Almuerzo con id ${lunch_id} no encontrado`);
    }
    ticketEntity.lunch = lunchEntity;

    /*
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
        throw new Error(`Almuerzo con id ${lunch_id} no encontrado`);
      }
      ticketEntity.lunch = lunchEntity;
    });*/

    return ticketEntity;
  }

  // Buscar por id y devolver ORM
  async findByIdORM(id: string): Promise<TicketEntity | null> {
    return this.ticketRepository.findOne({ where: { id }, relations: ['user', 'lunch'] });
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
  async save(ticket: Ticket): Promise<Ticket> {
    const ticketEntity = await this.mapToORM(ticket, ticket.user_email, ticket.lunch_id);
    const savedEntity = await this.ticketRepository.save(ticketEntity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(ticket: Ticket) {
    const ticketEntity = await this.mapToORM(ticket, ticket.user_email, ticket.lunch_id);
    const savedEntity = await this.ticketRepository.update(ticketEntity.id, ticketEntity);
    //return this.mapToDomain(savedEntity);
  }

  // Borrar por id
  async delete(id: string): Promise<void> {
    return this.ticketRepository.delete(id).then(() => {});
  }

  // Marcar como usado
  async markAsUsed(id: string): Promise<boolean> {
    const ticketEntity = await this.findByIdORM(id);
    if (!ticketEntity) {
      throw new Error(`Ticket con id ${id} no encontrado`);
    }
    ticketEntity.state = TicketState.USED;
    ticketEntity.used_at = new Date();
    const savedEntity = await this.ticketRepository.update({ id: ticketEntity.id } , ticketEntity);

    return savedEntity.affected === 1;
    //return this.mapToDomain(savedEntity);
  }
  async findTicketsByUser(email: string): Promise<Ticket[]> {
    const ticketEntities = await this.ticketRepository.find({ where: { user: { email } }, relations: ['user', 'lunch'] });
    return ticketEntities.map(entity => this.mapToDomain(entity));
  }

}
