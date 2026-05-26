import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UsersModule } from './users/users.module';
import { LunchesModule } from './lunches/lunches.module';
import { TicketsModule } from './tickets/tickets.module';
import { RechargesModule } from './recharges/recharges.module';

import { User } from './users/user.entity';
import { Lunch } from './lunches/lunch.entity';
import { Ticket } from './tickets/ticket.entity';
import { Recharge } from './recharges/recharge.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || '1234',
      database: process.env.DB_NAME || 'placita_speed_db',
      entities: [User, Lunch, Ticket, Recharge],
      synchronize: process.env.NODE_ENV !== 'production',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    }),
    UsersModule,
    LunchesModule,
    TicketsModule,
    RechargesModule,
  ],
})
export class AppModule {}
