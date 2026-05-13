import { Entity, Column, PrimaryColumn, OneToMany } from "typeorm";
import { RechargeEntity } from "../recharge/recharge.entity";
import { TicketEntity } from "../ticket/ticket.entity";

export enum UserRole {
    ADMIN = 'ADMIN',
    USER = 'USER'
}

@Entity('user')
export class UserEntity {
    @PrimaryColumn({type: 'varchar', length: 254})
    email!: string

    @Column({type: 'enum', enum: UserRole, default: UserRole.USER})
    role!: UserRole

    @Column({type: 'decimal', precision: 10, scale: 2, default: 0})
    virtual_balance!: number

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at!: Date

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    last_access!: Date

    @OneToMany(()=> TicketEntity, ticket => ticket.user)
    tickets!: TicketEntity[]

    @OneToMany(() => RechargeEntity, recharge => recharge.user)
    recharges!: RechargeEntity[]
}