import { Injectable } from '@nestjs/common';
import { User, UserRole } from '@domain/user/user';
import { Ticket, TicketState } from '@domain/ticket/ticket';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

@Injectable()
export class ValidateTicketService {
    constructor(
        private readonly userRepository: UserRepositoryPort,
        private readonly ticketRepository: TicketRepositoryPort
    ) {}

    async execute(adminEmail: string, ticketId: string): Promise<Ticket> {
    // Validar que sea ADMIN
    const admin: User|null = await this.userRepository.findByEmail(adminEmail);
    if (!admin) {
      throw new Error('Usuario no encontrado');
    }
    if (admin.role !== UserRole.ADMIN) {
      throw new Error('No tienes permisos para validar tickets. Se requiere rol ADMIN.');
    }

    // Buscar ticket
    const ticket: Ticket|null = await this.ticketRepository.findById(ticketId);
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
    return ticket;
  }
}
