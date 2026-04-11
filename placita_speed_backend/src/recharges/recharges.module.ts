import { Module } from '@nestjs/common';
import { RechargesService } from './recharges.service';
import { RechargesController } from './recharges.controller';
import { Recharge } from './recharge.entity';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [TypeOrmModule.forFeature([Recharge])],
  exports: [TypeOrmModule],
  providers: [RechargesService],
  controllers: [RechargesController]
})
export class RechargesModule {}
