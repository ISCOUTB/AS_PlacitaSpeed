import 'package:placita_speed_frontend/domain/entities/user_entity.dart';

/// Interfaz del Repositorio de Autenticación - Capa de Dominio
/// Define los contratos que debe cumplir cualquier implementación de autenticación
abstract class AuthRepository {
  /// Realiza el login del usuario
  /// Retorna un [UserEntity] si la autenticación es exitosa
  Future<UserEntity> login(String email, String password);

  /// Realiza el registro de un nuevo usuario
  Future<UserEntity> register(String email, String password, String name);

  /// Obtiene el usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Realiza el logout del usuario
  Future<void> logout();

  /// Verifica si hay un usuario autenticado
  Future<bool> isAuthenticated();
}
