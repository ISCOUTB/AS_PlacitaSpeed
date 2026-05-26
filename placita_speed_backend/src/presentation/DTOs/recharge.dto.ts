import { IsNumber, IsPositive } from 'class-validator';

export class BuyCreditsDto {
  @IsNumber({}, { message: 'El monto debe ser un número' })
  @IsPositive({ message: 'El monto debe ser mayor a 0' })
  value!: number;
}
