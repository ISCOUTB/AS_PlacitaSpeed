import { Module } from '@nestjs/common';

import { TicketController } from './ticket.controller';
import { ConsultTicketsByUserService } from '@application/ticket/consult-tickets-by-user.service';
import { CreateTicketService } from '@application/ticket/create-ticket.service';
import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';
import { TicketTypeormRepository } from '@infrastructure/typeorm/ticket/ticket-typeorm.repository';
import { LunchTypeormRepository } from '@infrastructure/typeorm/lunch/lunch-typeorm.repository';
import { LunchRepositoryPort } from '@domain/lunch/lunch-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { UserTypeormRepository } from '@infrastructure/typeorm/user/user-typeorm.repository';
import { BcryptJwtAuthAdapter } from '@infrastructure/auth/bcrypt-jwt-auth.adapter';
import { ValidateTicketService } from '@application/user/validate-ticket.service';

@Module({
  controllers: [TicketController],
  providers: [
    ConsultTicketsByUserService,
    CreateTicketService,
    ValidateTicketService,
    UserTypeormRepository,
    LunchTypeormRepository,
    TicketTypeormRepository,
    BcryptJwtAuthAdapter,
    {
      provide: TicketRepositoryPort,
      useClass: TicketTypeormRepository,
    },
    {
      provide: LunchRepositoryPort,
      useClass: LunchTypeormRepository,
    },
    {
      provide: UserRepositoryPort,
      useClass: UserTypeormRepository,
    }
]
})
export class TicketModule {}
