import {IsString, IsEmail, IsNotEmpty, MinLength, IsOptional, IsIn, IsNumber} from 'class-validator';
import { UserRole } from '../user.entity';

export class CreateUserDto {
    @IsEmail()
    @IsNotEmpty()
    email: string;
}