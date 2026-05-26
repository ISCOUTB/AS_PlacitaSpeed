import { IsEmail, IsNotEmpty, IsNumber, IsPositive } from 'class-validator';

export class CreateTicketDto {
    @IsEmail()
    @IsNotEmpty()
    userEmail: string;

    @IsNumber()
    @IsPositive()
    lunchId: number;
}
