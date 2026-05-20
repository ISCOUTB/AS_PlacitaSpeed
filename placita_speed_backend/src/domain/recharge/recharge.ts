export enum RechargeState {
    PENDING = 'PENDING',
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED'
}

export class Recharge{
    id!: string;
    value!: number;
    state!: RechargeState;
    started_at!: Date;
    ended_at?: Date;
    user_email!: string;
}