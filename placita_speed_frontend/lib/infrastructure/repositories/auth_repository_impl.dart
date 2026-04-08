import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';

/// Implementación del Repositorio de Autenticación - Capa de Infraestructura
/// Por ahora, solo contiene lógica dummy para el MVP sin funcionalidades reales
class AuthRepositoryImpl extends AuthRepository {
  /// En una implementación real, aquí se llamaría al backend API
  /// Para el MVP visual, solo retornamos datos dummy

  @override
  Future<UserEntity> login(String email, String password) async {
    // Será implementado cuando el backend esté disponible
    await Future.delayed(const Duration(milliseconds: 500));
    return const UserEntity(
      id: '1',
      email: 'estudiante@utb.edu.co',
      name: 'Estudiante UTB',
      userType: 'student',
      virtualBalance: 50000.0,
    );
  }

  @override
  Future<UserEntity> register(
      String email, String password, String name) async {
    // Será implementado cuando el backend esté disponible
    await Future.delayed(const Duration(milliseconds: 500));
    return UserEntity(
      id: '2',
      email: email,
      name: name,
      userType: 'student',
      virtualBalance: 0.0,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Será implementado cuando el backend esté disponible
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  @override
  Future<void> logout() async {
    // Será implementado cuando el backend esté disponible
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> isAuthenticated() async {
    // Será implementado cuando el backend esté disponible
    await Future.delayed(const Duration(milliseconds: 300));
    return false;
  }
}
