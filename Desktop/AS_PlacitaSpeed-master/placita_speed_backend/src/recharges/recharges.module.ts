import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RechargesService } from './recharges.service';
import { RechargesController } from './recharges.controller';
import { Recharge } from './recharge.entity';
import { UsersModule } from 'src/users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Recharge]),
    UsersModule,
  ],
  providers: [RechargesService],
  controllers: [RechargesController],
})
export class RechargesModule {}
