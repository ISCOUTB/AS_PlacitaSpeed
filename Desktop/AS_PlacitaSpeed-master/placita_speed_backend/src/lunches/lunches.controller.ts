import { Controller, Get, Post, Patch, Delete, Body, Param } from '@nestjs/common';
import { LunchesService } from './lunches.service';
import { CreateLunchDto, UpdateLunchDto } from './dto/lunch.dto';

@Controller('lunches')
export class LunchesController {
    constructor(private lunchesService: LunchesService) {}

    @Get()
    async getLunches() {
        return this.lunchesService.getLunches();
    }

    @Get(':id')
    async getLunch(@Param('id') id: number) {
        return this.lunchesService.getLunch(id);
    }

    @Post()
    async createLunch(@Body() dto: CreateLunchDto) {
        return this.lunchesService.createLunch(dto);
    }

    @Patch(':id')
    async updateLunch(@Param('id') id: number, @Body() dto: UpdateLunchDto) {
        return this.lunchesService.updateLunch(id, dto);
    }

    @Delete(':id')
    async deleteLunch(@Param('id') id: number) {
        return this.lunchesService.deleteLunch(id);
    }
}
