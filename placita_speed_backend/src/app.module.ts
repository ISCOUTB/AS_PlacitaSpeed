import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { UsersController } from './users/users.controller';
import { UsersService } from './users/users.service';
import { UsersModule } from './users/users.module';
import { User } from './users/user.entity';

@Module({
  imports: [
    UsersModule,
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'postgres',
      password: '1234',
      database: 'placita_speed_db',
      entities: [User],
      synchronize: true // solo para desarrollo, no usar en producción
    })
  ],
  controllers: [UsersController],
  providers: [UsersService],
})
export class AppModule {
  constructor(private dataSource: DataSource) {}
}
