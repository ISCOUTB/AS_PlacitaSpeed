import { Entity, Column, OneToMany, PrimaryGeneratedColumn, ManyToOne } from "typeorm";
import { UserEntity } from "../user/user.entity";
import { RechargeState } from "@domain/recharge/recharge";

@Entity('recharge')
export class RechargeEntity {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({type: 'decimal', precision: 10, scale: 2})
    value!: number;

    @Column({type: 'enum', enum: RechargeState, default: RechargeState.PENDING})
    state!: RechargeState;

    @Column({type: 'timestamp', default: () => 'CURRENT_TIMESTAMP'})
    started_at!: Date;

    @Column({type: 'timestamp', nullable: true})
    ended_at?: Date;

    @ManyToOne(() => UserEntity, user => user.recharges, {nullable: false})
    user!: UserEntity
}