import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';
import 'package:placita_speed_frontend/infrastructure/repositories/auth_repository_impl.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  late AuthRepository _authRepository;

  AppConfig._internal() {
    _initializeDependencies();
  }

  factory AppConfig() {
    return _instance;
  }

  void _initializeDependencies() {
    _authRepository = AuthRepositoryImpl();
  }

  AuthRepository get authRepository => _authRepository;

  static const String appName = 'Placita Speed';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplicación para la compra rápida de almuerzos en la UTB';
  static const bool isProduction = false;
}
