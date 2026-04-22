import { User } from '../user/user'

export enum RechargeState {
    PENDING = 'PENDING',
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED'
}

export class Recharge{
    id: string;
    value: number;
    state: string;
    started_at: Date;
    ended_at: Date | null;
    user: User;

    public constructor(
        id: string,
        value: number,
        state: string,
        started_at: Date,
        ended_at: Date | null,
        user: User
    ) {
        this.id = id;
        this.value = value;
        this.state = state;
        this.started_at = started_at;
        this.ended_at = ended_at;
        this.user = user;
    }
}