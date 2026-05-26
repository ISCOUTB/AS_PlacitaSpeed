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
    return TicketEntity(
      ticketId: json['ticket_id'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : null,
      lunchName: json['lunch']['name'] as String,
      lunchPrice: double.parse(json['lunch']['virtual_price'].toString()),
      userEmail: json['user']['email'] as String,
    );
  }

  @override
  List<Object?> get props =>
      [ticketId, state, createdAt, usedAt, lunchName, lunchPrice, userEmail];
}
