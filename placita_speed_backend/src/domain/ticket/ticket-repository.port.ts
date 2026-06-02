import { Injectable } from '@nestjs/common';
import { Ticket } from './ticket';
import { RepositoryPort } from '@domain/repository.port';

@Injectable()
export abstract class TicketRepositoryPort extends RepositoryPort<Ticket> {
  abstract find(id: string): Promise<Ticket | null>;
  abstract markAsUsed(id: string): Promise<boolean>;
  abstract findByUser(email: string): Promise<Ticket[]>;
  abstract delete(id: string): void;
}
