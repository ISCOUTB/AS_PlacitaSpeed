import { Injectable } from '@nestjs/common';
import { Ticket, TicketState } from '@domain/ticket/ticket';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class CreateTicketService {
  constructor(
    private readonly ticketRepository: TicketRepositoryPort,
    private readonly lunchRepository: LunchRepositoryPort,
    private readonly userRepository: UserRepositoryPort,
  ) {}

  async execute(email: string, lunchId: number): Promise<Ticket> {
    // Obtener almuerzo y validar existencia
    const lunch = await this.lunchRepository.findById(lunchId);
    if (!lunch) {
      throw new Error('Almuerzo no encontrado');
    }

    // Obtener usuario y validar saldo
    const user = await this.userRepository.findByEmail(email);
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
    await this.userRepository.update(user);

    // Crear ticket
    const ticket = new Ticket();
    ticket.state = TicketState.NO_USED;
    ticket.used_at = undefined;
    ticket.created_at = new Date();
    ticket.user_email = email;
    ticket.lunch_id = lunchId;

    return this.ticketRepository.save(ticket);
  }
}
