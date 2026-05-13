import { Ticket } from './ticket';

export interface TicketRepositoryPort {
    findById(id: string): Promise<Ticket | null>;
    findAll(): Promise<Ticket[]>;
    save(ticket: Ticket, user_email: string, lunch_id: number): Promise<Ticket>;
    update(ticket: Ticket, user_email: string, lunch_id: number): Promise<Ticket>;
    delete(id: string): Promise<void>;
}
