import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { UsersController } from './users/users.controller';
import { UsersService } from './users/users.service';
import { UsersModule } from './users/users.module';
import { User } from './users/user.entity';

import { LunchesController } from './lunches/lunches.controller';
import { LunchesService } from './lunches/lunches.service';
import { LunchesModule } from './lunches/lunches.module';
import { Lunch } from './lunches/lunch.entity';

import { TicketsModule } from './tickets/tickets.module';
import { TicketsController } from './tickets/tickets.controller';
import { TicketsService } from './tickets/tickets.service';
import { Ticket } from './tickets/ticket.entity';

@Module({
  imports: [
    UsersModule,
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'postgres',
      password: '1234',
      database: 'placita_speed_db',
      entities: [User, Lunch, Ticket],
      synchronize: true // solo para desarrollo, no usar en producción
    }),
    LunchesModule,
    TicketsModule
  ],
  controllers: [UsersController, LunchesController, TicketsController],
  providers: [UsersService, LunchesService, TicketsService],
})
export class AppModule {
  constructor(private dataSource: DataSource) {}
}
