import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppDataSource } from './infrastructure/typeorm/data-source';

import { LunchModule } from './presentation/lunch/lunch.module';
import { LunchTypeormRepository } from './infrastructure/typeorm/lunch/lunch-typeorm.repository';
import { LunchController } from './presentation/lunch/lunch.controller';

import { UserModule } from './presentation/user/user.module';
import { UserTypeormRepository } from './infrastructure/typeorm/user/user-typeorm.repository';
import { UserController } from './presentation/user/user.controller';

import { TicketModule } from './presentation/ticket/ticket.module';
import { TicketTypeormRepository } from './infrastructure/typeorm/ticket/ticket-typeorm.repository';
import { TicketController } from './presentation/ticket/ticket.controller';

import { RechargeModule } from './presentation/recharge/recharge.module';
import { RechargeTypeormRepository } from './infrastructure/typeorm/recharge/recharge-typeorm.repository';
import { RechargeController } from './presentation/recharge/recharge.controller';


@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options),
    LunchModule,
    RechargeModule,
    TicketModule,
    UserModule
  ],
  controllers: [
    LunchController,
    TicketController,
    RechargeController,
    UserController
  ],
  providers: [
    LunchTypeormRepository,
    UserTypeormRepository,
    TicketTypeormRepository,
    RechargeTypeormRepository
  ],
})
export class AppModule {}
