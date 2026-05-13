import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { DataSource, MoreThan, Repository } from 'typeorm';

import { Lunch } from '@domain/lunch/lunch';
import { LunchEntity } from '../lunch/lunch.entity';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

import { Ticket } from '@domain/ticket/ticket';
import { TicketEntity } from '../ticket/ticket.entity';
import { TicketTypeormRepository } from '../ticket/ticket-typeorm.repository';

// TODO: Quitar el forwardRef y mejorar la inyección de dependencias para evitar acoplamientos circulares

/**
 * Adaptador de persistencia TypeORM para Lunch
 * Implementa el puerto LunchRepositoryPort del dominio
 * Mapea entre LunchEntity (esquema ORM) y Lunch (entidad de dominio)
 */
@Injectable()
export class LunchTypeormRepository implements LunchRepositoryPort {
    private lunchRepository: Repository<LunchEntity>;

    constructor(
        private dataSource: DataSource,
        @Inject(forwardRef(() => TicketTypeormRepository)) private ticketRepository: TicketTypeormRepository
    ) {
        this.lunchRepository = this.dataSource.getRepository(LunchEntity);
    }

    mapToDomain(lunchEntity: LunchEntity): Lunch {
        let ticketlist: Ticket[];
        if (lunchEntity.tickets) {
            ticketlist = lunchEntity.tickets.map(ticket => this.ticketRepository.mapToDomain(ticket));
        } else {
            ticketlist = [];
        }

        return new Lunch(
            lunchEntity.id,
            lunchEntity.name,
            lunchEntity.description,
            Number(lunchEntity.virtual_price), // TypeORM puede devolver Decimal, convertir a number
            lunchEntity.stock,
            ticketlist
        );
    }

    mapToORM(lunch: Lunch): LunchEntity {
        let ticketEntlist: TicketEntity[];
        if (lunch.tickets) {
            ticketEntlist = lunch.tickets.map(ticket => this.ticketRepository.mapToORM(ticket));
        } else {
            ticketEntlist = [];
        }
        const lunchEntity = new LunchEntity();
        lunchEntity.id = lunch.id;
        lunchEntity.name = lunch.name;
        lunchEntity.description = lunch.description;
        lunchEntity.virtual_price = lunch.virtual_price;
        lunchEntity.stock = lunch.stock;
        lunchEntity.tickets = ticketEntlist;
        return lunchEntity;
    }

    /**
     * Buscar un lunch por ID
     */
    async findById(id: number): Promise<Lunch | null> {
        const lunchEntity = await this.lunchRepository.findOne({
            where: { id },
        });

        if (!lunchEntity) {
            return null;
        }

        return this.mapToDomain(lunchEntity);
    }

    /**
     * Obtener todos los lunches
     */
    async findAll(): Promise<Lunch[]> {
        const lunchEntities = await this.lunchRepository.find();
        return lunchEntities.map(entity => this.mapToDomain(entity));
    }

    /**
     * Obtener todos los lunches disponibles (con stock > 0)
     */
    async findAvailable(): Promise<Lunch[]> {
        const lunchEntities = await this.lunchRepository.find({
            where: {
                stock: MoreThan(0)
            },
        });

        return lunchEntities.map(entity => this.mapToDomain(entity));
    }

    /**
     * Guardar un nuevo lunch
     */
    async save(lunch: Lunch): Promise<Lunch> {
        const lunchEntity = this.mapToORM(lunch);
        const savedEntity = await this.lunchRepository.save(lunchEntity);
        return this.mapToDomain(savedEntity);
    }

    /**
     * Actualizar un lunch existente
     */
    async update(lunch: Lunch): Promise<Lunch> {
        const lunchEntity = this.mapToORM(lunch);
        await this.lunchRepository.update({ id: lunch.id }, lunchEntity);

        // Refrescar desde BD para obtener el estado actualizado
        const updatedEntity = await this.lunchRepository.findOne({
            where: { id: lunch.id }
        });

        if (!updatedEntity) {
            throw new Error(`Lunch with id ${lunch.id} not found`);
        }

        return this.mapToDomain(updatedEntity);
    }

    /**
     * Eliminar un lunch por ID
     */
    async delete(id: number): Promise<void> {
        const result = await this.lunchRepository.delete({ id });
        if (result.affected === 0) {
            throw new Error(`Lunch with id ${id} not found`);
        }
  }
}
