import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String userType;
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
