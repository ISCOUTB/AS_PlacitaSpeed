import { Injectable } from '@nestjs/common';
import { Recharge, RechargeState } from '@domain/recharge/recharge';
import { RechargeRepositoryPort } from '@domain/recharge/recharge-repository.port';
import { UserRepositoryPort } from '@domain/user/user-repository.port';

@Injectable()
export class BuyCredits {
  constructor(
    private readonly rechargeRepository: RechargeRepositoryPort,
    private readonly userRepository: UserRepositoryPort,
  ) {}

  /**
   * Recarga el saldo virtual del usuario autenticado.
   * No tiene pasarela de pago real; simplemente suma el monto al saldo.
   */
  async execute(email: string, amount: number): Promise<Recharge> {
    if (amount <= 0) {
      throw new Error('El monto de recarga debe ser mayor a 0');
    }

    const user = await this.userRepository.find(email);
    if (!user) {
      throw new Error('Usuario no encontrado');
    }

    // Sumar al saldo
    user.virtual_balance += amount;
    this.userRepository.update(user);

    // Registrar la recarga como exitosa
    const recharge = new Recharge();
    recharge.value = amount;
    recharge.state = RechargeState.SUCCESS;
    recharge.started_at = new Date();
    recharge.ended_at = new Date();
    recharge.user_email = email;

    return this.rechargeRepository.create(recharge);
  }
}
