import { Module } from '@nestjs/common';

import { LunchTypeormRepository } from '@infrastructure/typeorm/lunch/lunch-typeorm.repository';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';

import { ConsultLunchesService } from '@application/lunch/consult-lunches.service';
import { LunchController } from './lunch.controller';

@Module({
  controllers: [LunchController],
  providers: [
    ConsultLunchesService,
    {
      provide: LunchRepositoryPort,
      useClass: LunchTypeormRepository,
    },
  ]
})
export class LunchModule {}
