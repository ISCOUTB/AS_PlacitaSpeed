import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  HttpException,
} from '@nestjs/common';
import { JwtGuard } from '../jwt.guard';
import { LoginDto, RegisterDto } from '../DTOs/user.dto';
import { AutenticateUserService } from '@application/user/autenticate-user.service';
import { ConsultUserDataService } from '@application/user/consult-user-data.service';
import { CreateUserService } from '@application/user/create-user.service';
import { LogoutUserService } from '@application/user/logout-user.service';


@Controller('api/users')
export class UserController {
  constructor(
    private readonly autenticate: AutenticateUserService,
    private readonly consultData: ConsultUserDataService,
    private readonly create: CreateUserService,
    private readonly logout: LogoutUserService,
  ) {}

  // ─── Autenticación ───────────────────────────────────────────────────────

  /**
   * POST /api/users/login
   * Recibe email y contraseña. Retorna un JWT si las credenciales son válidas.
   * También actualiza el campo last_access del usuario.
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: LoginDto) {
    try {
      const token = await this.autenticate.execute(body.email, body.password);
      return { token };
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.UNAUTHORIZED);
    }
  }

  /**
   * POST /api/users/register
   * Crea un nuevo usuario con email, contraseña y rol.
   */
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() body: RegisterDto) {
    try {
      const user = await this.create.execute(body.email, body.password, body.role);
      return user;
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * POST /api/users/logout
   * Cierra la sesión del usuario autenticado.
   * Con JWT stateless, el cliente debe eliminar el token.
   */
  @UseGuards(JwtGuard)
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logoutSession(@Request() req) {
    console.log(`User ${req.user.email} logged out.`);
    try {
      return await this.logout.execute(req.user.email);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.BAD_REQUEST);
    }
  }

  // ─── Datos del usuario autenticado ───────────────────────────────────────

  /**
   * GET /api/users/me
   * Retorna los datos básicos del usuario autenticado (sin contraseña).
   */
  @UseGuards(JwtGuard)
  @Get('me')
  async getMe(@Request() req) {
    try {
      return await this.consultData.execute(req.user.email);
    } catch (e: any) {
      throw new HttpException(e.message, HttpStatus.NOT_FOUND);
    }
  }
}
