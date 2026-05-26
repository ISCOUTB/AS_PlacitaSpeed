import { Injectable } from '@nestjs/common';
import { Ticket } from '@domain/ticket/ticket';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

@Injectable()
export class ConsultTicketsByUserService {
  constructor(private readonly ticketRepository: TicketRepositoryPort) {}

  async execute(email: string): Promise<Ticket[]> {
    return this.ticketRepository.findTicketsByUser(email);
  }
}