import { IsEmail, IsNotEmpty, IsNumber, IsPositive } from 'class-validator';

export class CreateRechargeDto {
    @IsEmail()
    @IsNotEmpty()
    userEmail: string;

    @IsNumber()
    @IsPositive()
    value: number;
}
