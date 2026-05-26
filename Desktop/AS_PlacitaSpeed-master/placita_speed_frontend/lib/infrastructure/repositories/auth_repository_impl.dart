import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  static const _users = [
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

  UserEntity? _currentUser;

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final match = _users.where(
      (u) => u['email'] == email.trim() && u['password'] == password,
    );

    if (match.isEmpty) {
      throw Exception('Correo o contraseña incorrectos');
    }

    final data = match.first;
    _currentUser = UserEntity(
      id: data['email'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      userType: data['userType'] as String,
      virtualBalance: data['virtualBalance'] as double,
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    throw UnimplementedError('Registro no disponible en modo offline');
  }

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Future<void> logout() async => _currentUser = null;

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;
}
