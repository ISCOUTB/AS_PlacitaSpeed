import { Controller } from '@nestjs/common';
import { RechargesService } from './recharges.service';

@Controller('recharges')
export class RechargesController {
    constructor(private rechargesService: RechargesService) {}
}
