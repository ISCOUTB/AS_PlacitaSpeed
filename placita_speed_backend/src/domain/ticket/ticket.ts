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
    user_email: string;
    lunch_id: number;

    public constructor(
        id: string,
        state: string,
        created_at: Date,
        used_at: Date | null,
        user_email: string,
        lunch_id: number
    ) {
        this.id = id;
        this.state = state;
        this.created_at = created_at;
        this.used_at = used_at;
        this.user_email = user_email;
        this.lunch_id = lunch_id;
    }
}