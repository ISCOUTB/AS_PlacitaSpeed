import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppDataSource } from './infrastructure/database/typeorm/config/data-source';

import { LunchDomainService } from './domain/lunch/lunch-domain.service';
import { LunchTypeormRepository } from './infrastructure/database/typeorm/lunch-typeorm.repository';
import { LunchController } from './presentation/lunch/lunch.controller';
import { LunchApplicationService } from './application/lunch/lunch-application.service';

import { UserDomainService } from './domain/user/user-domain.service';
import { CreateUserService } from './application/user/create-user.use-case';
import { UserTypeormRepository } from './infrastructure/database/typeorm/user-typeorm.repository';
import { UserController } from './presentation/user/user.controller';
import { UserApplicationService } from './application/user/user-application.service';

import { TicketDomainService } from './domain/ticket/ticket-domain.service';
import { CreateTicketService } from './application/ticket/create-ticket.use-case';
import { TicketApplicationService } from './application/ticket/ticket-application.service';
import { TicketTypeormRepository } from './infrastructure/database/typeorm/ticket-typeorm.repository';
import { TicketController } from './presentation/ticket/ticket.controller';

import { RechargeDomainService } from './domain/recharge/recharge-domain.service';
import { CreateRechargeService } from './application/recharge/create-recharge.use-case';
import { RechargeApplicationService } from './application/recharge/recharge-application.service';
import { RechargeTypeormRepository } from './infrastructure/database/typeorm/recharge-typeorm.repository';
import { RechargeController } from './presentation/recharge/recharge.controller';

import { LunchModule } from './presentation/lunch/lunch.module';
import { RechargeModule } from './presentation/recharge/recharge.module';
import { TicketModule } from './presentation/ticket/ticket.module';
import { UserModule } from './presentation/user/user.module';

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
    LunchDomainService,
    LunchTypeormRepository,
    LunchApplicationService,
    UserDomainService,
    CreateUserService,
    UserTypeormRepository,
    UserApplicationService,
    TicketDomainService,
    CreateTicketService,
    TicketApplicationService,
    TicketTypeormRepository,
    RechargeDomainService,
    CreateRechargeService,
    RechargeApplicationService,
    RechargeTypeormRepository
  ],
})
export class AppModule {}
