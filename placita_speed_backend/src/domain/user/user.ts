export enum UserRole {
    ADMIN = 'ADMIN',
    USER = 'USER'
}

export class User {
    email!: string;
    password!: string;
    role!: UserRole;
    virtual_balance: number = 0;
    created_at!: Date;
    last_access?: Date;
}