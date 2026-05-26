import { IsString, IsNotEmpty, IsNumber, IsPositive, IsOptional, MaxLength, Min } from 'class-validator';

export class CreateLunchDto {
    @IsString()
    @IsNotEmpty()
    @MaxLength(60)
    name: string;

    @IsString()
    @IsNotEmpty()
    @MaxLength(200)
    description: string;

    @IsNumber()
    @IsPositive()
    virtual_price: number;

    @IsNumber()
    @Min(0)
    stock: number;
}

export class UpdateLunchDto {
    @IsOptional()
    @IsString()
    @MaxLength(60)
    name?: string;

    @IsOptional()
    @IsString()
    @MaxLength(200)
    description?: string;

    @IsOptional()
    @IsNumber()
    @IsPositive()
    virtual_price?: number;

    @IsOptional()
    @IsNumber()
    @Min(0)
    stock?: number;
}
