import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { Lunch } from './lunch.entity'
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class LunchesService {
    constructor(
        @InjectRepository(Lunch)
        private lunchesRepository: Repository<Lunch>,
    ) {}

    async getLunches(): Promise<Lunch[]> {
        return this.lunchesRepository.find();
    }

    async getLunch(lunch_id: number): Promise<Lunch|null> {
        return this.lunchesRepository.findOne({ where: { lunch_id } });
    }
}
