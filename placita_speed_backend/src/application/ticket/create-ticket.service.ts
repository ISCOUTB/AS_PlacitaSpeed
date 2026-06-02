import { Injectable } from '@nestjs/common';
import { Ticket, TicketState } from '@domain/ticket/ticket';
import { User } from '@domain/user/user';
import { Lunch } from '@domain/lunch/lunch';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class CreateTicket {
  constructor(
    private readonly ticketRepository: TicketRepositoryPort,
    private readonly lunchRepository: LunchRepositoryPort,
    private readonly userRepository: UserRepositoryPort,
  ) {}

  async execute(email: string, lunchId: number): Promise<any> {
    // Obtener almuerzo y validar existencia
    const lunch = await this.lunchRepository.find(lunchId);
    if (!lunch) {
      throw new Error('Almuerzo no encontrado');
    }

    if (lunch.stock <= 0) {
      throw new Error('Almuerzo agotado');
    }

    // Obtener usuario y validar saldo
    const user = await this.userRepository.find(email);
    if (!user) {
      throw new Error('Usuario no encontrado');
    }

    if (Number(user.virtual_balance) < Number(lunch.virtual_price)) {
      throw new Error(
        `Saldo insuficiente. Saldo actual: ${user.virtual_balance}, precio: ${lunch.virtual_price}`,
      );
    }

    // Descontar saldo
    user.virtual_balance -= lunch.virtual_price;
    this.userRepository.update(user);

    // Reducir stock
    lunch.stock -= 1;
    this.lunchRepository.update(lunch);

    // Crear ticket
    const ticket = new Ticket();
    ticket.state = TicketState.NO_USED;
    ticket.used_at = undefined;
    ticket.created_at = new Date();
    ticket.user_email = email;
    ticket.lunch_id = lunchId;

    const savedTicket = await this.ticketRepository.create(ticket);
    return this.buildTicketResponse(savedTicket, user, lunch);
  }

  private buildTicketResponse(ticket: Ticket, user: User, lunch: Lunch): any {
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
