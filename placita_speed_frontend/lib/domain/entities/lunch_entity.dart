class LunchEntity {
  final int id;
  final String name;
  final String description;
  final double virtualPrice;
  final int stock;

  LunchEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.virtualPrice,
    required this.stock,
  });

  factory LunchEntity.fromJson(Map<String, dynamic> json) {
    return LunchEntity(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      virtualPrice: double.tryParse((json['virtual_price'] ?? json['virtualPrice'] ?? 0).toString()) ?? 0.0,
      stock: (json['stock'] is int) ? json['stock'] as int : int.tryParse((json['stock'] ?? '0').toString()) ?? 0,
    );
  }
}
