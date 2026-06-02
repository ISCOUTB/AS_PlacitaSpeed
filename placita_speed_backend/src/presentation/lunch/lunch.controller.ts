import {
  Controller,
  Get,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConsultLunches } from '@application/lunch/consult-lunches.service';

@Controller('api/lunches')
export class LunchController {
  constructor(private readonly consultLunches: ConsultLunches) {}

  @Get()
  async getLunches() {
    try {
      return await this.consultLunches.execute();
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
