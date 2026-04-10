import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LunchesService } from './lunches.service';
import { LunchesController } from './lunches.controller';
import { Lunch } from './lunch.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Lunch])],
    exports: [TypeOrmModule],
    providers: [LunchesService],
    controllers: [LunchesController]
})
export class LunchesModule {}
