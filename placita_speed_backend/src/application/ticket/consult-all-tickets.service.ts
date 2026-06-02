import { Injectable } from '@nestjs/common';
import { Ticket } from '@domain/ticket/ticket';
import { User, UserRole } from '@domain/user/user';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class ConsultAllTickets {
  constructor(
    private readonly ticketRepository: TicketRepositoryPort,
    private readonly userRepository: UserRepositoryPort,
    private readonly lunchRepository: LunchRepositoryPort,
  ) {}

  async execute(adminEmail: string): Promise<any[]> {
    const admin: User | null = await this.userRepository.find(adminEmail);
    if (!admin) {
      throw new Error('Usuario no encontrado');
    }
    if (admin.role !== UserRole.ADMIN) {
      throw new Error('No tienes permisos. Se requiere rol ADMIN.');
    }
    const tickets = await this.ticketRepository.findAll();
    return Promise.all(tickets.map((ticket) => this.buildTicketResponse(ticket)));
  }

  private async buildTicketResponse(ticket: Ticket): Promise<any> {
    const [user, lunch] = await Promise.all([
      this.userRepository.find(ticket.user_email),
      this.lunchRepository.find(ticket.lunch_id),
    ]);

    if (!user) throw new Error('Usuario no encontrado');
    if (!lunch) throw new Error('Almuerzo no encontrado');

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
