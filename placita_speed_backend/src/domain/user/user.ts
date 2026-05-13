export enum UserRole {
    ADMIN = 'ADMIN',
    USER = 'USER'
}

export class User {
    email: string;
    role: UserRole;
    virtual_balance: number;
    created_at: Date;
    last_access: Date;

    public constructor(
        email: string,
        role: UserRole,
        virtual_balance: number,
        created_at: Date,
        last_access: Date,
    ) {
        this.email = email;
        this.role = role;
        this.virtual_balance = virtual_balance;
        this.created_at = created_at;
        this.last_access = last_access;
    }
}