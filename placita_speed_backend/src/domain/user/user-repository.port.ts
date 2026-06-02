import { Injectable } from '@nestjs/common';
import { User } from './user';
import { RepositoryPort } from '@domain/repository.port';

@Injectable()
export abstract class UserRepositoryPort extends RepositoryPort<User> {
    abstract find(email: string): Promise<User | null>;
    abstract delete(email: string): void;
    abstract updateLastAccess(email: string): void;
}