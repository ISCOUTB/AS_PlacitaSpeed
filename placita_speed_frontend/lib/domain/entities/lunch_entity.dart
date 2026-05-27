import 'package:equatable/equatable.dart';

class LunchEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double virtualPrice;
  final int stock;

  const LunchEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.virtualPrice,
    required this.stock,
  });

  factory LunchEntity.fromJson(Map<String, dynamic> json) {
    return LunchEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      virtualPrice: double.parse(json['virtual_price'].toString()),
      stock: json['stock'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, description, virtualPrice, stock];
}
