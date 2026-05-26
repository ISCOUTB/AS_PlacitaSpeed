import { IsEmail, IsNotEmpty, IsNumber, IsPositive } from 'class-validator';

export class CreateUserDto {
    @IsEmail()
    @IsNotEmpty()
    email: string;
}

export class UpdateBalanceDto {
    @IsNumber()
    @IsPositive()
    value: number;
}
