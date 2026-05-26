import { Ticket } from "src/tickets/ticket.entity";
import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from "typeorm";

@Entity()
export class Lunch {
    @PrimaryGeneratedColumn()
    id: number

    @Column({type: 'varchar', length: 60, unique: true})
    name: string

    @Column({type: 'varchar', length: 200})
    description: string

    @Column({type: 'decimal', precision: 10, scale: 2})
    virtual_price: number

    @Column({type: 'int'})
    stock: number

    @OneToMany(()=> Ticket, ticket => ticket.lunch)
    tickets: Ticket[]
}