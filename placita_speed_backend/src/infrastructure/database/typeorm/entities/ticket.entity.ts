import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from "typeorm";
import { LunchEntity } from "./lunch.entity";
import { UserEntity } from "./user.entity";

export enum TicketState {
    NO_USED = 'NO_USED',
    USED = 'USED',
    EXPIRED = 'EXPIRED'
}

@Entity('ticket')
export class TicketEntity{
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({type: 'enum', enum: TicketState, default: TicketState.NO_USED})
    state!: string;

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at!: Date;

    @Column({type: 'timestamp', nullable: true})
    used_at?: Date;

    @ManyToOne(() => UserEntity, user => user.tickets, {nullable: false})
    user!: UserEntity

    @ManyToOne(() => LunchEntity, lunch => lunch.tickets, {nullable: false})
    lunch!: LunchEntity
}