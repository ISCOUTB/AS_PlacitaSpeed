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
} from '@nestjs/common';
import { JwtGuard } from '../jwt.guard';
import { BuyCreditsDto } from '../DTOs/recharge.dto';
import { BuyCreditsService } from '@application/recharge/buy-credits.service';
import { ConsultRechargesByUserService } from '@application/recharge/consult-recharges-by-user.service';

@Controller('api/recharges')
export class RechargeController {
  constructor(
    private readonly buyCredits: BuyCreditsService,
    private readonly consultRechargesByUser: ConsultRechargesByUserService
  ) {}

  /**sudo apt  install docker-compose
   * GET /api/recharges
   * Retorna la lista de recargas del usuario autenticado.
   */
  @UseGuards(JwtGuard)
  @Get()
  async getUserRecharges(@Request() req) {
    try {
      return await this.consultRechargesByUser.execute(req.user.email);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * POST /api/recharges/buy
   * Recarga saldo virtual del usuario autenticado.
   * Body: { value: number }
   */
  @UseGuards(JwtGuard)
  @Post('buy')
  @HttpCode(HttpStatus.CREATED)
  async forBuyingCredits(@Request() req, @Body() body: BuyCreditsDto) {
    try {
      return await this.buyCredits.execute(req.user.email, body.value);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.BAD_REQUEST);
    }
  }
}
