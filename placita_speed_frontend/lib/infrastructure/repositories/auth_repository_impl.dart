import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:placita_speed_frontend/config/api_config.dart';
import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  static final _client = http.Client();
  static final _base = Uri.parse(ApiConfig.baseUrl);

  static const _offlineUsers = [
    {
      'email': 'estudiante@utb.edu.co',
      'password': 'estudiante123',
      'name': 'Fabian Granados',
      'userType': 'student',
      'virtualBalance': 48500.0,
    },
    {
      'email': 'admin@utb.edu.co',
      'password': 'admin123',
      'name': 'Administrador UTB',
      'userType': 'admin',
      'virtualBalance': 0.0,
    },
  ];

  String? _token;
  UserEntity? _currentUser;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _client
          .post(
            _base.replace(path: '/api/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = _decodeBody(response.body);

      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Correo o contraseña incorrectos');
      }

      final token = body['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('La respuesta de autenticación no incluye token');
      }

      _token = token;
      _currentUser = await _fetchCurrentUser(token);
      return _currentUser!;
    } on TimeoutException catch (_) {
      return _loginOffline(email, password, 'El servidor tardó demasiado en responder');
    } on SocketException catch (_) {
      return _loginOffline(email, password, 'No fue posible conectar con el servidor');
    } on http.ClientException catch (_) {
      return _loginOffline(email, password, 'No fue posible conectar con el servidor');
    }
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    throw UnimplementedError('Registro no disponible en la interfaz actual');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    if (_token == null) {
      return null;
    }

    _currentUser = await _fetchCurrentUser(_token!);
    return _currentUser;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> logout() async {
    final token = _token;

    if (token != null) {
      try {
        await _client
            .post(
              _base.replace(path: '/api/users/logout'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Logout stateless: limpiamos el cliente aunque falle la llamada.
      }
    }

    _token = null;
    _currentUser = null;
  }

  @override
  Future<bool> isAuthenticated() async => _token != null;

  Future<UserEntity> _fetchCurrentUser(String token) async {
    final response = await _client
        .get(
          _base.replace(path: '/api/users/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'No se pudo cargar el usuario');
    }

    return _mapUser(body);
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

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
      (user) => user['email'] == email.trim() && user['password'] == password,
    );

    if (match.isEmpty) {
      throw Exception('$cause. Credenciales inválidas en modo local.');
    }

    final user = match.first;
    _token = 'offline:${user['email']}';
    _currentUser = UserEntity(
      id: user['email'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
      userType: user['userType'] as String,
      virtualBalance: (user['virtualBalance'] as num).toDouble(),
    );
    return _currentUser!;
  }
}
