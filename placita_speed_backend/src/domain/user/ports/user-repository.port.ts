import { User } from '../user';

export interface UserRepositoryPort {
    findById(email: string): Promise<User | null>;
    findAll(): Promise<User[]>;
    save(user: User): Promise<User>;
    update(user: User): Promise<User>;
    delete(email: string): Promise<void>;
}
