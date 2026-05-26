import { Entity, Column, OneToMany, PrimaryGeneratedColumn, ManyToOne } from "typeorm";
import { User } from "src/users/user.entity";

export enum RechargeState {
    PENDING = 'PENDING',
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED'
}

@Entity()
export class Recharge{
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({type: 'decimal', precision: 10, scale: 2})
    value: number;

    @Column({type: 'enum', enum: RechargeState, default: RechargeState.PENDING})
    state: string;

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    started_at: Date;

    @Column({type: 'timestamp', nullable: true})
    ended_at: Date;

    @ManyToOne(() => User, user => user.recharges, {nullable: false})
    user: User
}