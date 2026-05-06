import { TicketTypeormRepository } from '@infrastructure/database/typeorm/ticket-typeorm.repository';
import { Controller, Get } from '@nestjs/common';

@Controller('ticket')
export class TicketController {
    constructor(private ticketRepository: TicketTypeormRepository) {}

    @Get()
    async findAll() {
        return await this.ticketRepository.findAll();
    }
}
