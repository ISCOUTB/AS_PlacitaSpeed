import { DataSource } from 'typeorm';
import { UserEntity } from '../entities/user.entity';
import { LunchEntity } from '../entities/lunch.entity';
import { RechargeEntity } from '../entities/recharge.entity';
import { TicketEntity } from '../entities/ticket.entity';


export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '1234',
  database: process.env.DB_NAME || 'placita_speed_db',
  entities: [UserEntity,LunchEntity,RechargeEntity,TicketEntity],
  synchronize: true,  // Solo en desarrollo
});