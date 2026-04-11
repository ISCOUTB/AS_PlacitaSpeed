import { Ticket } from "src/tickets/ticket.entity";
import { Entity, Column, PrimaryColumn, OneToMany } from "typeorm";

export enum UserRole {
    ADMIN = 'ADMIN',
    USER = 'USER'
}

@Entity()
export class User {
    @PrimaryColumn({type: 'varchar', length: 254})
    email: string

    @Column({type: 'enum', enum: UserRole, default: UserRole.USER})
    role: UserRole

    @Column({type: 'decimal', precision: 10, scale: 2, default: 0})
    saldo_virtual: number

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at: Date

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    last_access: Date

    @OneToMany(()=> Ticket, ticket => ticket.user)
    tickets: Ticket[]
}