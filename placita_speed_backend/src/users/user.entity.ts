import { Entity, Column, PrimaryColumn, OneToMany } from "typeorm";
import { Recharge } from "src/recharges/recharge.entity";
import { Ticket } from "src/tickets/ticket.entity";

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
    virtual_balance: number

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at: Date

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    last_access: Date

    @OneToMany(()=> Ticket, ticket => ticket.user)
    tickets: Ticket[]

    @OneToMany(() => Recharge, recharge => recharge.user)
    recharges: Recharge[]
}