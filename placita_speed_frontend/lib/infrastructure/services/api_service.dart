import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/config/api_config.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';
import 'package:placita_speed_frontend/domain/entities/lunch_entity.dart';

class ApiService {
  static final _client = http.Client();
  static final _base = Uri.parse(ApiConfig.baseUrl);

  static Future<TicketEntity> createTicket({
    required int lunchId,
  }) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/tickets/buy'),
          headers: await _authorizedJsonHeaders(),
          body: jsonEncode({'lunch_id': lunchId}),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response.body);

    if (response.statusCode == 201) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Error al crear el ticket');
  }

  static Future<TicketEntity> useTicket(String ticketId) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/tickets/validate/$ticketId'),
          headers: await _authorizedJsonHeaders(),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response.body);

    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Error al verificar el ticket');
  }

  static Future<TicketEntity> getTicket(String ticketId) async {
    final response = await _client
        .get(
          _base.replace(path: '/api/tickets/$ticketId'),
          headers: await _authorizedJsonHeaders(),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response.body);

    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }

    throw Exception(body['message'] ?? 'Ticket no encontrado');
  }

  static Future<Map<String, String>> _authorizedJsonHeaders() async {
    final token = await AppConfig().authRepository.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesión de nuevo');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static dynamic _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(body);
  }

  static Future<List<LunchEntity>> getLunches() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/lunches'),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response.body);

    if (response.statusCode == 200) {
      if (body is List) {
        return body
            .map((e) => LunchEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <LunchEntity>[];
    }

    throw Exception((body is Map && body['message'] != null) ? body['message'] : 'Error al cargar almuerzos');
  }
}
