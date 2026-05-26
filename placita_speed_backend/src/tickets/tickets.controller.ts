import { Controller, Get, Post, Patch, Body, Param } from '@nestjs/common';
import { TicketsService } from './tickets.service';
import { CreateTicketDto } from './dto/ticket.dto';

@Controller('tickets')
export class TicketsController {
    constructor(private ticketsService: TicketsService) {}

    @Get()
    async getTickets() {
        return this.ticketsService.getTickets();
    }

    @Get('user/:email')
    async getTicketsByUser(@Param('email') email: string) {
        return this.ticketsService.getTicketsByUser(email);
    }

    @Get(':ticket_id')
    async getTicket(@Param('ticket_id') ticket_id: string) {
        return this.ticketsService.getTicket(ticket_id);
    }

    @Post()
    async createTicket(@Body() dto: CreateTicketDto) {
        return this.ticketsService.createTicket(dto);
    }

    @Patch(':ticket_id/use')
    async useTicket(@Param('ticket_id') ticket_id: string) {
        return this.ticketsService.useTicket(ticket_id);
    }

    @Patch(':ticket_id/expire')
    async expireTicket(@Param('ticket_id') ticket_id: string) {
        return this.ticketsService.expireTicket(ticket_id);
    }
}
