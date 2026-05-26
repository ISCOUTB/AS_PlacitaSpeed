import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppDataSource } from './infrastructure/typeorm/data-source';

import { LunchModule } from './presentation/lunch/lunch.module';
import { UserModule } from './presentation/user/user.module';
import { TicketModule } from './presentation/ticket/ticket.module';
import { RechargeModule } from './presentation/recharge/recharge.module';

@Module({
  imports: [
    TypeOrmModule.forRoot(AppDataSource.options),
    LunchModule,
    RechargeModule,
    TicketModule,
    UserModule
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
