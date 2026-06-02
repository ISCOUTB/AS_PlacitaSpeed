import { Injectable } from '@nestjs/common';
import { Ticket } from '@domain/ticket/ticket';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class ConsultTicketsByUser {
  constructor(
    private readonly ticketRepository: TicketRepositoryPort,
    private readonly userRepository: UserRepositoryPort,
    private readonly lunchRepository: LunchRepositoryPort,
  ) {}

  async execute(email: string): Promise<any[]> {
    const tickets = await this.ticketRepository.findByUser(email);
    return Promise.all(tickets.map((ticket) => this.buildTicketResponse(ticket)));
  }

  async executeById(ticketId: string): Promise<any> {
    const ticket = await this.ticketRepository.find(ticketId);
    if (!ticket) {
      throw new Error('Ticket no encontrado');
    }

    return this.buildTicketResponse(ticket);
  }

  private async buildTicketResponse(ticket: Ticket): Promise<any> {
    const [user, lunch] = await Promise.all([
      this.userRepository.find(ticket.user_email),
      this.lunchRepository.find(ticket.lunch_id),
    ]);

    if (!user) {
      throw new Error('Usuario no encontrado');
    }

    if (!lunch) {
      throw new Error('Almuerzo no encontrado');
    }

    return {
      ticket_id: ticket.id,
      state: ticket.state,
      created_at: ticket.created_at,
      used_at: ticket.used_at ?? null,
      user: {
        email: user.email,
        role: user.role,
        virtual_balance: Number(user.virtual_balance),
      },
      lunch: {
        id: lunch.id,
        name: lunch.name,
        description: lunch.description,
        virtual_price: Number(lunch.virtual_price),
        stock: lunch.stock,
      },
    };
  }
}
