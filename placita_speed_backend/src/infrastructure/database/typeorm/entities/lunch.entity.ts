import { Entity, PrimaryColumn, Column, OneToMany } from 'typeorm';
import { TicketEntity } from './ticket.entity';

@Entity('lunch')
export class LunchEntity {
  @PrimaryColumn({ type: 'int' })
  id!: number;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'text'})
  description!: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  virtual_price!: number;

  @Column({ type: 'int', default: 0 })
  stock!: number;

  @OneToMany(() => TicketEntity, ticket => ticket.lunch)
  tickets!: TicketEntity[];
}