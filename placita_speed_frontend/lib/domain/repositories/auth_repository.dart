import 'package:placita_speed_frontend/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password, String name);
  Future<UserEntity?> getCurrentUser();
  Future<String?> getToken();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
