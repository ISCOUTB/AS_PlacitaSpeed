export enum TicketState {
    NO_USED = 'NO_USED',
    USED = 'USED',
    EXPIRED = 'EXPIRED'
}

export class Ticket{
    id!: string;
    state!: TicketState;
    created_at!: Date;
    used_at?: Date;
    user_email!: string;
    lunch_id!: number;
}