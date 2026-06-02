import { TicketRepositoryPort } from '@domain/ticket/ticket-repository.port';

import { AuthPort } from '@domain/user/auth.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { BcryptJwtAuthAdapter } from '@infrastructure/auth/bcrypt-jwt-auth.adapter';
import { TicketTypeormRepository } from '@infrastructure/typeorm/ticket/ticket-typeorm.repository';
import { UserTypeormRepository } from '@infrastructure/typeorm/user/user-typeorm.repository';
import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { AutenticateUser } from '@application/user/autenticate-user.service';
import { ConsultUserData } from '@application/user/consult-user-data.service';
import { CreateUser } from '@application/user/create-user.service';
import { LogoutUser } from '@application/user/logout-user.service';
import { LunchTypeormRepository } from '@infrastructure/typeorm/lunch/lunch-typeorm.repository';

@Module({
  controllers: [ UserController],
  providers: [
    AutenticateUser,
    ConsultUserData,
    CreateUser,
    LogoutUser,
    UserTypeormRepository,
    LunchTypeormRepository,
    BcryptJwtAuthAdapter,
    {
      provide: TicketRepositoryPort,
      useClass: TicketTypeormRepository,
    },
    {
      provide: AuthPort,
      useClass: BcryptJwtAuthAdapter,
    },
    {
      provide: UserRepositoryPort,
      useClass: UserTypeormRepository,
    }
  ]
})
export class UserModule {}
