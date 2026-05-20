import { Injectable } from '@nestjs/common';
import { Recharge } from '@domain/recharge/recharge';
import { Ticket } from '../ticket/ticket';
import { User } from './user';

@Injectable()
export abstract class UserRepositoryPort {
    abstract findByEmail(email: string): Promise<User | null>;
    abstract findAll(): Promise<User[]>;
    abstract save(user: User): Promise<User>;
    abstract update(user: User): void;
    abstract delete(email: string): void;
    abstract updateLastAccess(email: string): void;
}