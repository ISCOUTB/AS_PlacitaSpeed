import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:placita_speed_frontend/config/api_config.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';

class ApiService {
  static final _client = http.Client();
  static final _base = Uri.parse(ApiConfig.baseUrl);

  static Future<TicketEntity> createTicket({
    required String userEmail,
    required int lunchId,
  }) async {
    final response = await _client
        .post(
          _base.replace(path: '/tickets'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userEmail': userEmail, 'lunchId': lunchId}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Error al crear el ticket');
  }

  static Future<TicketEntity> useTicket(String ticketId) async {
    final response = await _client
        .patch(
          _base.replace(path: '/tickets/$ticketId/use'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Error al verificar el ticket');
  }

  static Future<TicketEntity> getTicket(String ticketId) async {
    final response = await _client
        .get(_base.replace(path: '/tickets/$ticketId'))
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Ticket no encontrado');
  }
}
