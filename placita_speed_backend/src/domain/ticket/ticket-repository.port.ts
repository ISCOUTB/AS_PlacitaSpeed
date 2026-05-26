import { Injectable } from '@nestjs/common';
import { Ticket } from './ticket';

@Injectable()
export abstract class TicketRepositoryPort {
    abstract findById(id: string): Promise<Ticket | null>;
    abstract findAll(): Promise<Ticket[]>;
    abstract save(ticket: Ticket): Promise<Ticket>;
    abstract update(ticket: Ticket): void;
    abstract delete(id: string): void;
    abstract markAsUsed(id: string): Promise<boolean>;
    abstract findTicketsByUser(email: string): Promise<Ticket[]>;
}
