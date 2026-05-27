import 'dart:async';
import 'dart:io';

import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';
import 'package:placita_speed_frontend/infrastructure/services/api_service.dart';
import 'package:placita_speed_frontend/infrastructure/services/auth_token.dart';

class AuthRepositoryImpl extends AuthRepository {
  static const _offlineUsers = [
    {
      'email': 'estudiante@utb.edu.co',
      'password': 'estudiante123',
      'name': 'Estudiante UTB',
      'userType': 'student',
      'virtualBalance': 50000.0,
    },
    {
      'email': 'admin@utb.edu.co',
      'password': 'admin123',
      'name': 'Administrador',
      'userType': 'admin',
      'virtualBalance': 0.0,
    },
  ];

  UserEntity? _currentUser;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final token = await ApiService.login(email, password);
      AuthToken.set(token);

      final data = await ApiService.getMe();
      _currentUser = _mapUser(data);
      return _currentUser!;
    } on TimeoutException catch (_) {
      return _loginOffline(email, password, 'El servidor tardó demasiado en responder');
    } on SocketException catch (_) {
      return _loginOffline(email, password, 'No fue posible conectar con el servidor');
    }
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    throw UnimplementedError('Registro no disponible en la interfaz actual');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    if (!AuthToken.isSet) return null;

    try {
      final data = await ApiService.getMe();
      _currentUser = _mapUser(data);
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getToken() async => AuthToken.token;

  @override
  Future<void> logout() async {
    try {
      if (AuthToken.isSet) {
        await ApiService.logout();
      }
    } catch (_) {}
    AuthToken.clear();
    _currentUser = null;
  }

  @override
  Future<bool> isAuthenticated() async => AuthToken.isSet;

  UserEntity _mapUser(Map<String, dynamic> data) {
    final role = (data['role'] ?? data['userType'] ?? 'USER').toString();
    final normalizedRole = role.toUpperCase() == 'ADMIN' ? 'admin' : 'student';
    final balanceValue = data['virtual_balance'] ?? data['virtualBalance'] ?? 0;

    return UserEntity(
      id: (data['email'] ?? data['id'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      name: (data['name'] ?? data['email'] ?? '').toString(),
      userType: normalizedRole,
      virtualBalance: double.tryParse(balanceValue.toString()) ?? 0.0,
    );
  }

  UserEntity _loginOffline(String email, String password, String cause) {
    final match = _offlineUsers.where(
      (u) => u['email'] == email.trim() && u['password'] == password,
    );

    if (match.isEmpty) {
      throw Exception('$cause. Credenciales inválidas en modo local.');
    }

    final u = match.first;
    AuthToken.set('offline:${u['email']}');
    _currentUser = UserEntity(
      id: u['email'] as String,
      email: u['email'] as String,
      name: u['name'] as String,
      userType: u['userType'] as String,
      virtualBalance: (u['virtualBalance'] as num).toDouble(),
    );
    return _currentUser!;
  }
}
