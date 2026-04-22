import { DataSource } from 'typeorm';
import { User } from '@domain/user/user';
import { Lunch } from '@domain/lunch/lunch';
import { Ticket } from '@domain/ticket/ticket';
import { Recharge } from '@domain/recharge/recharge';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '1234',
  database: process.env.DB_NAME || 'placita_speed_db',
  entities: [User, Lunch, Ticket, Recharge],
  synchronize: process.env.NODE_ENV !== 'production',  // Solo en desarrollo
  logging: process.env.NODE_ENV === 'development',
});