import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { Ticket, TicketState } from './ticket.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { UsersService } from 'src/users/users.service';
import { LunchesService } from 'src/lunches/lunches.service';
import { CreateTicketDto } from './dto/ticket.dto';

@Injectable()
export class TicketsService {
    constructor(
        @InjectRepository(Ticket)
        private ticketRepository: Repository<Ticket>,
        private usersService: UsersService,
        private lunchesService: LunchesService,
    ) {}

    async getTickets(): Promise<Ticket[]> {
        return this.ticketRepository.find({ relations: ['user', 'lunch'] });
    }

    async getTicketsByUser(email: string): Promise<Ticket[]> {
        return this.ticketRepository.find({
            where: { user: { email } },
            relations: ['lunch'],
        });
    }

    async getTicket(ticket_id: string): Promise<Ticket> {
        const ticket = await this.ticketRepository.findOne({
            where: { ticket_id },
            relations: ['user', 'lunch'],
        });
        if (!ticket) throw new HttpException('Ticket not found', HttpStatus.NOT_FOUND);
        return ticket;
    }

    async createTicket(dto: CreateTicketDto): Promise<Ticket> {
        const user = await this.usersService.findOne(dto.userEmail);
        const lunch = await this.lunchesService.getLunch(dto.lunchId);

        if (Number(user.virtual_balance) < Number(lunch.virtual_price)) {
            throw new HttpException('Insufficient balance', HttpStatus.BAD_REQUEST);
        }
        if (lunch.stock <= 0) {
            throw new HttpException('No stock available', HttpStatus.BAD_REQUEST);
        }

        await this.usersService.deductBalance(dto.userEmail, Number(lunch.virtual_price));
        await this.lunchesService.decrementStock(dto.lunchId);

        const ticket = this.ticketRepository.create({ user, lunch });
        return this.ticketRepository.save(ticket);
    }

    async useTicket(ticket_id: string): Promise<Ticket> {
        const ticket = await this.getTicket(ticket_id);
        if (ticket.state !== TicketState.NO_USED) {
            throw new HttpException('Ticket already used or expired', HttpStatus.BAD_REQUEST);
        }
        await this.ticketRepository.update({ ticket_id }, {
            state: TicketState.USED,
            used_at: new Date(),
        });
        return this.getTicket(ticket_id);
    }

    async expireTicket(ticket_id: string): Promise<Ticket> {
        const ticket = await this.getTicket(ticket_id);
        if (ticket.state !== TicketState.NO_USED) {
            throw new HttpException('Ticket already used or expired', HttpStatus.BAD_REQUEST);
        }
        await this.ticketRepository.update({ ticket_id }, { state: TicketState.EXPIRED });
        return this.getTicket(ticket_id);
    }
}
