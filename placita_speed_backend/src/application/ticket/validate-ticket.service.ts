import { Injectable } from '@nestjs/common';
import { User, UserRole } from '@domain/user/user';
import { Ticket, TicketState } from '@domain/ticket/ticket';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

@Injectable()
export class ValidateTicket {
    constructor(
        private readonly userRepository: UserRepositoryPort,
      private readonly ticketRepository: TicketRepositoryPort,
      private readonly lunchRepository: LunchRepositoryPort,
    ) {}

    async execute(adminEmail: string, ticketId: string): Promise<any> {
    // Validar que sea ADMIN
    const admin: User|null = await this.userRepository.find(adminEmail);
    if (!admin) {
      throw new Error('Usuario no encontrado');
    }
    if (admin.role !== UserRole.ADMIN) {
      throw new Error('No tienes permisos para validar tickets. Se requiere rol ADMIN.');
    }

    // Buscar ticket
    const ticket: Ticket|null = await this.ticketRepository.find(ticketId);
    if (!ticket) {
      throw new Error('Ticket no encontrado');
    }
    if (ticket.state === TicketState.USED) {
      throw new Error('El ticket ya fue utilizado');
    }

    // Marcar como usado
    await this.ticketRepository.markAsUsed(ticketId);

    ticket.state = TicketState.USED;
    ticket.used_at = new Date();
    const user = await this.userRepository.find(ticket.user_email);
    const lunch = await this.lunchRepository.find(ticket.lunch_id);

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
