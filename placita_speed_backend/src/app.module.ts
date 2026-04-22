import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppDataSource } from './infrastructure/database/typeorm/config/data-source';

import { LunchDomainService } from './domain/lunch/lunch-domain.service';
import { LunchTypeormService } from './infrastructure/database/typeorm/lunch-typeorm.repository';
import { LunchController } from './presentation/lunch/lunch.controller';
import { LunchApplicationService } from './application/lunch/lunch-application.service';

import { UserDomainService } from './domain/user/user-domain.service';
import { CreateUserService } from './application/user/create-user.use-case';
import { UserTypeormService } from './infrastructure/database/typeorm/user-typeorm.repository';
import { UserController } from './presentation/user/user.controller';
import { UserApplicationService } from './application/user/user-application.service';

import { TicketDomainService } from './domain/ticket/ticket-domain.service';
import { CreateTicketService } from './application/ticket/create-ticket.use-case';
import { TicketApplicationService } from './application/ticket/ticket-application.service';
import { TicketTypeormService } from './infrastructure/database/typeorm/ticket-typeorm.repository';
import { TicketController } from './presentation/ticket/ticket.controller';

import { RechargeDomainService } from './domain/recharge/recharge-domain.service';
import { CreateRechargeService } from './application/recharge/create-recharge.use-case';
import { RechargeApplicationService } from './application/recharge/recharge-application.service';
import { RechargeTypeormService } from './infrastructure/database/typeorm/recharge-typeorm.repository';
import { RechargeController } from './presentation/recharge/recharge.controller';

@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options),
  ],
  controllers: [
    LunchController,
    UserController,
    TicketController,
    RechargeController],
  providers: [
    LunchDomainService,
    LunchTypeormService,
    LunchApplicationService,
    UserDomainService,
    CreateUserService,
    UserTypeormService,
    UserApplicationService,
    TicketDomainService,
    CreateTicketService,
    TicketApplicationService,
    TicketTypeormService,
    RechargeDomainService,
    CreateRechargeService,
    RechargeApplicationService,
    RechargeTypeormService],
})
export class AppModule {}
