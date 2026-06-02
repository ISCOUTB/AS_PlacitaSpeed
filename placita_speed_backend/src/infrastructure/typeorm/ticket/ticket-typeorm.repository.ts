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
  repository: Repository<TicketEntity>;

  constructor(
    private dataSource: DataSource,
    private userRepository: UserTypeormRepository,
    private lunchRepository: LunchTypeormRepository
  ) {
    super();
    this.repository = this.dataSource.getRepository(TicketEntity);
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

    let userEntity: UserEntity | null = await this.userRepository.findORM(user_email);
    if (!userEntity) {
      throw new Error(`Usuario con email ${user_email} no encontrado`);
    }
    ticketEntity.user = userEntity;

    let lunchEntity: LunchEntity | null = await this.lunchRepository.findORM(lunch_id);
    if (!lunchEntity) {
      throw new Error(`Almuerzo con id ${lunch_id} no encontrado`);
    }
    ticketEntity.lunch = lunchEntity;

    return ticketEntity;
  }

  // Buscar por id y devolver ORM
  async findORM(id: string): Promise<TicketEntity | null> {
    return this.repository.findOne({
      where: { id },
      relations: ['user', 'lunch']
   });
  }

  // Buscar por id
  async find(id: string): Promise<Ticket | null> {
    const entity = await this.findORM(id);
    return entity ? this.mapToDomain(entity) : null;
  }

  // Buscar todos
  async findAll(): Promise<Ticket[]> {
    const entities = await this.repository.find({
      relations: ['user', 'lunch']
    });
    return entities.map(entity => this.mapToDomain(entity));
  }

  // Guardar
  async create(ticket: Ticket): Promise<Ticket> {
    const entity = await this.mapToORM(ticket, ticket.user_email, ticket.lunch_id);
    const savedEntity = await this.repository.save(entity);
    return this.mapToDomain(savedEntity);
  }

  // Actualizar
  async update(ticket: Ticket) {
    const entity = await this.mapToORM(ticket, ticket.user_email, ticket.lunch_id);
    await this.repository.update(entity.id, entity);
  }

  // Borrar por id
  async delete(id: string) {
    await this.repository.delete(id);
  }

  // Marcar como usado
  async markAsUsed(id: string): Promise<boolean> {
    const ticketEntity = await this.findORM(id);
    if (!ticketEntity) {
      throw new Error(`Ticket con id ${id} no encontrado`);
    }
    ticketEntity.state = TicketState.USED;
    ticketEntity.used_at = new Date();
    const savedEntity = await this.repository.update({ id: ticketEntity.id } , ticketEntity);

    return savedEntity.affected === 1;
  }
  async findByUser(email: string): Promise<Ticket[]> {
    const entities = await this.repository.find({ where: { user: { email } }, relations: ['user', 'lunch'] });
    return entities.map(entity => this.mapToDomain(entity));
  }

}
