import { Ticket } from './ticket';

export interface TicketRepositoryPort {
    findById(id: string): Promise<Ticket | null>;
    findAll(): Promise<Ticket[]>;
    save(ticket: Ticket): Promise<Ticket>;
    update(ticket: Ticket): Promise<Ticket>;
    delete(id: string): Promise<void>;
}
