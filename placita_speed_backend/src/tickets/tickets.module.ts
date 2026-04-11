import { Module } from '@nestjs/common';
import { TicketsService } from './tickets.service';
import { TicketsController } from './tickets.controller';
import { Ticket } from './ticket.entity';
import { TypeOrmModule } from '@nestjs/typeorm/dist/typeorm.module';

@Module({
  imports: [TypeOrmModule.forFeature([Ticket])],
  exports: [TypeOrmModule],
  providers: [TicketsService],
  controllers: [TicketsController],
})
export class TicketsModule {}
