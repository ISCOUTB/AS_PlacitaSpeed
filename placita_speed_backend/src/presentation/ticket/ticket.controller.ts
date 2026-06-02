import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Request,
  HttpException,
  HttpStatus,
  HttpCode,
  Param,
} from '@nestjs/common';
import { JwtGuard } from '../jwt.guard';
import { CreateTicketDto, ValidateTicketDto } from '../DTOs/ticket.dto';
import { ConsultAllTickets } from '@application/ticket/consult-all-tickets.service';
import { ConsultTicketsByUser } from '@application/ticket/consult-tickets-by-user.service';
import { CreateTicket } from '@application/ticket/create-ticket.service';
import { ValidateTicket } from '@application/ticket/validate-ticket.service';

@Controller('api/tickets')
export class TicketController {
  constructor(
    private readonly consultAllTickets: ConsultAllTickets,
    private readonly consultTicketsByUser: ConsultTicketsByUser,
    private readonly createTicket: CreateTicket,
    private readonly validateTicketSe: ValidateTicket
  ) {}

  /**
   * GET /api/tickets
   * Retorna la lista de tickets comprados por el usuario autenticado.
   */
  @UseGuards(JwtGuard)
  @Get()
  async getTicketsByUser(@Request() req) {
    try {
      return await this.consultTicketsByUser.execute(req.user.email);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * GET /api/tickets/all
   * Retorna todos los tickets. Solo accesible por usuarios con rol ADMIN.
   */
  @UseGuards(JwtGuard)
  @Get('all')
  async getAllTickets(@Request() req) {
    try {
      return await this.consultAllTickets.execute(req.user.email);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.FORBIDDEN);
    }
  }

  /**
   * GET /api/tickets/:ticket_id
   * Retorna el detalle de un ticket específico.
   */
  @UseGuards(JwtGuard)
  @Get(':ticket_id')
  async getTicket(@Param('ticket_id') ticketId: string) {
    try {
      return await this.consultTicketsByUser.executeById(ticketId);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.NOT_FOUND);
    }
  }

  /**
   * POST /api/tickets/buy
   * Crea un ticket para el almuerzo indicado.
   * Descuenta el precio virtual del saldo del usuario autenticado.
   * Body: { lunch_id: number }
   */
  @UseGuards(JwtGuard)
  @Post('buy')
  @HttpCode(HttpStatus.CREATED)
  async buyTicket(@Request() req, @Body() body: CreateTicketDto) {
    try {
      return await this.createTicket.execute(req.user.email, body.lunch_id);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.BAD_REQUEST);
    }
  }

  // ─── Validación de ticket (solo ADMIN) ───────────────────────────────────

  /**
   * POST /api/tickets/validate/:ticket_id
   * Marca un ticket como USED. Solo accesible por usuarios con rol ADMIN.
   */
  @UseGuards(JwtGuard)
  @Post('validate/:ticket_id')
  @HttpCode(HttpStatus.OK)
  async validateTicket(@Request() req, @Param() params: ValidateTicketDto) {
    try {
      return await this.validateTicketSe.execute(req.user.email, params.ticket_id);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.FORBIDDEN);
    }
  }
}
