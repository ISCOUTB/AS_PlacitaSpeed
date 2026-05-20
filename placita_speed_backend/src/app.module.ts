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
import { ConsultLunchesService } from './application/lunch/consult-lunches.service';
import { CreateUserService } from './application/user/create-user.service';
import { LogoutUserService } from './application/user/logout-user.service';
import { AutenticateUserService } from './application/user/autenticate-user.service';
import { ValidateTicketService } from './application/user/validate-ticket.service';
import { ConsultUserDataService } from './application/user/consult-user-data.service';
import { ConsultTicketsByUserService } from './application/ticket/consult-tickets-by-user.service';
import { CreateTicketService } from './application/ticket/create-ticket.service';
import { ConsultRechargesByUserService } from './application/recharge/consult-recharges-by-user.service';
import { BuyCreditsService } from './application/recharge/buy-credits.service';

import { AuthPort } from './domain/user/auth.port';
import { UserRepositoryPort } from './domain/user/user-repository.port';
import { TicketRepositoryPort } from './domain/ticket/ticket-repository.port';
import { RechargeRepositoryPort } from './domain/recharge/recharge-repository.port';
import { LunchRepositoryPort } from './domain/lunch/lunch-repository.port';

@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options),
    LunchModule,
    RechargeModule,
    TicketModule,
    UserModule
  ],
  controllers: [/*
    LunchController,
    TicketController,
    RechargeController,
    UserController*/
  ],
  providers: [/*
    LunchTypeormRepository,
    UserTypeormRepository,
    TicketTypeormRepository,
    RechargeTypeormRepository,
    ConsultLunchesService,
    CreateUserService,
    LogoutUserService,
    AutenticateUserService,
    ValidateTicketService,
    ConsultUserDataService,
    ConsultTicketsByUserService,
    CreateTicketService,
    ConsultRechargesByUserService,
    BuyCreditsService*/
  ],
})
export class AppModule {}
