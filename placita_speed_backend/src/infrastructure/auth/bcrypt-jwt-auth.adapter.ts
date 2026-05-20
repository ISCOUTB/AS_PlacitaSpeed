import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { AuthPort } from '../../domain/user/auth.port';

const JWT_SECRET = process.env.JWT_SECRET ?? 'placita_secret_dev_2024';
const SALT_ROUNDS = 10;

@Injectable()
export class BcryptJwtAuthAdapter implements AuthPort {
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  }

  async comparePassword(plain: string, hashed: string): Promise<boolean> {
    return bcrypt.compare(plain, hashed);
  }

  generateToken(payload: Record<string, unknown>): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '8h' });
  }

  verifyToken(token: string): Record<string, unknown> | null {
    try {
      return jwt.verify(token, JWT_SECRET) as Record<string, unknown>;
    } catch {
      return null;
    }
  }
}
