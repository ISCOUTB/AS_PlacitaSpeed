import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { Lunch } from './lunch.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateLunchDto, UpdateLunchDto } from './dto/lunch.dto';

@Injectable()
export class LunchesService {
    constructor(
        @InjectRepository(Lunch)
        private lunchesRepository: Repository<Lunch>,
    ) {}

    async getLunches(): Promise<Lunch[]> {
        return this.lunchesRepository.find();
    }

    async getLunch(id: number): Promise<Lunch> {
        const lunch = await this.lunchesRepository.findOne({ where: { id } });
        if (!lunch) throw new HttpException('Lunch not found', HttpStatus.NOT_FOUND);
        return lunch;
    }

    async createLunch(dto: CreateLunchDto): Promise<Lunch> {
        const exists = await this.lunchesRepository.findOne({ where: { name: dto.name } });
        if (exists) throw new HttpException('Lunch already exists', HttpStatus.CONFLICT);
        return this.lunchesRepository.save(dto);
    }

    async updateLunch(id: number, dto: UpdateLunchDto): Promise<Lunch> {
        await this.getLunch(id);
        await this.lunchesRepository.update({ id }, dto);
        return this.getLunch(id);
    }

    async deleteLunch(id: number): Promise<void> {
        await this.getLunch(id);
        await this.lunchesRepository.delete({ id });
    }

    async decrementStock(id: number): Promise<void> {
        const lunch = await this.getLunch(id);
        if (lunch.stock <= 0) {
            throw new HttpException('No stock available', HttpStatus.BAD_REQUEST);
        }
        await this.lunchesRepository.update({ id }, { stock: lunch.stock - 1 });
    }
}
