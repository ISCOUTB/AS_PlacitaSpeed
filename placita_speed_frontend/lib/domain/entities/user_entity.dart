import 'package:equatable/equatable.dart';

/// Entidad de Usuario - Capa de Dominio
/// Representa un usuario de la aplicación Placita Speed
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String userType; // 'student' o 'admin'
  final double virtualBalance;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.virtualBalance = 0.0,
  });

  @override
  List<Object?> get props => [id, email, name, userType, virtualBalance];
}
