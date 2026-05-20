import {
  Controller,
  Get,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConsultLunchesService } from '@application/lunch/consult-lunches.service';

@Controller('api/lunch')
export class LunchController {
  constructor(private readonly consultLunches: ConsultLunchesService) {}

  @Get()
  async getLunches() {
    try {
      return await this.consultLunches.execute();
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
