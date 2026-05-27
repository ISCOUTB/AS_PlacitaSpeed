import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final String ticketId;
  final String state;
  final DateTime createdAt;
  final DateTime? usedAt;
  final String lunchName;
  final double lunchPrice;
  final String userEmail;

  const TicketEntity({
    required this.ticketId,
    required this.state,
    required this.createdAt,
    this.usedAt,
    required this.lunchName,
    required this.lunchPrice,
    required this.userEmail,
  });

  bool get isValid => state == 'NO_USED';
  bool get isUsed => state == 'USED';
  bool get isExpired => state == 'EXPIRED';

  factory TicketEntity.fromJson(Map<String, dynamic> json) {
    final lunch = json['lunch'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    final ticketIdValue = json['ticket_id'] ?? json['id'] ?? '';
    final createdAtValue = json['created_at'] ?? json['createdAt'];
    final usedAtValue = json['used_at'] ?? json['usedAt'];
    final lunchNameValue =
      lunch?['name'] ?? json['lunch_name'] ?? json['lunchName'] ?? 'Almuerzo';
    final lunchPriceValue = lunch?['virtual_price'] ??
      json['lunch_price'] ??
      json['lunchPrice'] ??
      0;
    final userEmailValue =
      user?['email'] ?? json['user_email'] ?? json['userEmail'] ?? '';

    return TicketEntity(
      ticketId: ticketIdValue.toString(),
      state: json['state'] as String,
      createdAt: DateTime.parse(createdAtValue.toString()),
      usedAt: usedAtValue != null
        ? DateTime.parse(usedAtValue.toString())
          : null,
      lunchName: lunchNameValue.toString(),
      lunchPrice: double.parse(lunchPriceValue.toString()),
      userEmail: userEmailValue.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [ticketId, state, createdAt, usedAt, lunchName, lunchPrice, userEmail];
}
