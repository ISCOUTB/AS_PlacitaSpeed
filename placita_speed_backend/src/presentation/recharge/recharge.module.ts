import { Module } from '@nestjs/common';

import { BuyCredits } from '@application/recharge/buy-credits.service';
import { ConsultRechargesByUser } from '@application/recharge/consult-recharges-by-user.service';
import { RechargeController } from './recharge.controller';

import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';
import { RechargeTypeormRepository } from '@infrastructure/typeorm/recharge/recharge-typeorm.repository';
import { UserRepositoryPort } from '@domain/user/user-repository.port';
import { UserTypeormRepository } from '@infrastructure/typeorm/user/user-typeorm.repository';
import { BcryptJwtAuthAdapter } from '@infrastructure/auth/bcrypt-jwt-auth.adapter';

@Module({
  controllers: [RechargeController],
  providers: [
    BuyCredits,
    ConsultRechargesByUser,
    UserTypeormRepository,
    RechargeTypeormRepository,
    BcryptJwtAuthAdapter,
    {
      provide: RechargeRepositoryPort,
      useClass: RechargeTypeormRepository,
    },
    {
      provide: UserRepositoryPort,
      useClass: UserTypeormRepository
    }
  ]
})
export class RechargeModule {}
