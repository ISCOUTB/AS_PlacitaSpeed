import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '1234',
  database: process.env.DB_NAME || 'placita_speed_db',
  entities: ["../entities/*"],  // Usar esquemas de infraestructura
  synchronize: process.env.NODE_ENV !== 'production',  // Solo en desarrollo
  logging: process.env.NODE_ENV === 'development',
});