import { Injectable } from '@nestjs/common';
import { Ticket } from './ticket.entity'
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class TicketsService {
    constructor(
        @InjectRepository(Ticket)
        private ticketRepository: Repository<Ticket>,
    ) {}
}
