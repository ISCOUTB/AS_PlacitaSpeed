import { IsNotEmpty, IsNumber, IsPositive, IsUUID } from 'class-validator';

export class CreateTicketDto {
  @IsNumber({}, { message: 'El id del almuerzo debe ser un número' })
  @IsPositive({ message: 'El id del almuerzo debe ser positivo' })
  lunch_id!: number;
}

export class ValidateTicketDto {
  @IsUUID('4', { message: 'El id del ticket debe ser un UUID válido' })
  @IsNotEmpty({ message: 'El id del ticket es requerido' })
  ticket_id!: string;
}
