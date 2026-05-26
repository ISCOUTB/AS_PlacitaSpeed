import { Lunch } from "src/lunches/lunch.entity";
import { User } from "src/users/user.entity";
import { Entity, Column, PrimaryGeneratedColumn, ManyToOne } from "typeorm";

export enum TicketState {
    NO_USED = 'NO_USED',
    USED = 'USED',
    EXPIRED = 'EXPIRED'
}

@Entity()
export class Ticket{
    @PrimaryGeneratedColumn('uuid')
    ticket_id: string;

    @Column({type: 'enum', enum: TicketState, default: TicketState.NO_USED})
    state: string;

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    created_at: Date;

    @Column({type: 'timestamp', nullable: true})
    used_at: Date;

    @ManyToOne(() => User, user => user.tickets, {nullable: false})
    user: User

    @ManyToOne(() => Lunch, lunch => lunch.tickets, {nullable: false})
    lunch: Lunch
}