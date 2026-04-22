import { Lunch } from "../lunch/lunch";
import { User } from "../user/user";

export enum TicketState {
    NO_USED = 'NO_USED',
    USED = 'USED',
    EXPIRED = 'EXPIRED'
}

export class Ticket{
    id: string;
    state: string;
    created_at: Date;
    used_at: Date | null;
    user: User;
    lunch: Lunch;

    public constructor(
        id: string,
        state: string,
        created_at: Date,
        used_at: Date | null,
        user: User,
        lunch: Lunch
    ) {
        this.id = id;
        this.state = state;
        this.created_at = created_at;
        this.used_at = used_at;
        this.user = user;
        this.lunch = lunch;
    }
}