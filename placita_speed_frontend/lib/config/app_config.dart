import 'package:placita_speed_frontend/domain/repositories/auth_repository.dart';
import 'package:placita_speed_frontend/infrastructure/repositories/auth_repository_impl.dart';

/// Configuración de la aplicación
/// Inyección de dependencias y configuración centralizada
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  late AuthRepository _authRepository;

  AppConfig._internal() {
    _initializeDependencies();
  }

  factory AppConfig() {
    return _instance;
  }

  /// Inicializa todas las dependencias de la aplicación
  void _initializeDependencies() {
    // Aquí se pueden agregar más repositorios y servicios conforme crezca la app
    _authRepository = AuthRepositoryImpl();
  }

  /// Getter para el repositorio de autenticación
  AuthRepository get authRepository => _authRepository;

  /// Información de la aplicación
  static const String appName = 'Placita Speed';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplicación para la compra rápida de almuerzos en la UTB';
  static const bool isProduction = false; // Cambiar a true en producción
}
