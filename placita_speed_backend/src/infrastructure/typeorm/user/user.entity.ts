import { Entity, Column, PrimaryColumn, OneToMany } from "typeorm";
import { RechargeEntity } from "../recharge/recharge.entity";
import { TicketEntity } from "../ticket/ticket.entity";
import { UserRole } from "@domain/user/user";

@Entity('user')
export class UserEntity {
    @PrimaryColumn({type: 'varchar', length: 254})
    email!: string

    @Column({type: 'varchar', length: 255, nullable: false})
    password!: string

    @Column({type: 'enum', enum: UserRole, default: UserRole.USER})
    role!: UserRole

    @Column({type: 'decimal', precision: 10, scale: 2, default: 0})
    virtual_balance!: number

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at!: Date

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    last_access?: Date

    @OneToMany(()=> TicketEntity, ticket => ticket.user)
    tickets!: TicketEntity[]

    @OneToMany(() => RechargeEntity, recharge => recharge.user)
    recharges!: RechargeEntity[]
}