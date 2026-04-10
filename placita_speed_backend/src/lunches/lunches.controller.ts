import { Controller, Get, Param } from '@nestjs/common';
import { LunchesService } from './lunches.service';
import { Lunch } from './lunch.entity';

@Controller('lunches')
export class LunchesController {
    constructor(private lunchesService: LunchesService) {}
    
    @Get()
    async getLunches() {
        return this.lunchesService.getLunches();
    }

    @Get(':lunch_id')
    async getLunch(@Param('lunch_id') lunch_id: number) {
        return this.lunchesService.getLunch(lunch_id);
    }
}
