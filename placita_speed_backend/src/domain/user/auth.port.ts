import { Injectable } from '@nestjs/common';

@Injectable()
export abstract class AuthPort {
  abstract hashPassword(password: string): Promise<string>;
  abstract comparePassword(plain: string, hashed: string): Promise<boolean>;
  abstract generateToken(payload: Record<string, unknown>): string;
  abstract verifyToken(token: string): Record<string, unknown> | null;
}
