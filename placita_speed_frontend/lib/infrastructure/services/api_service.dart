import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:placita_speed_frontend/config/api_config.dart';
import 'package:placita_speed_frontend/domain/entities/lunch_entity.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';
import 'package:placita_speed_frontend/infrastructure/services/auth_token.dart';

class ApiService {
  static final _client = http.Client();
  static final _base = Uri.parse(ApiConfig.baseUrl);

  static Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth && AuthToken.token != null) {
      headers['Authorization'] = 'Bearer ${AuthToken.token}';
    }
    return headers;
  }

  static Future<String> login(String email, String password) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/users/login'),
          headers: _headers(),
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body['token'] as String;
    }
    throw Exception(body['message'] ?? 'Error al iniciar sesión');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/users/me'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    }
    throw Exception(body['message'] ?? 'Error al obtener datos del usuario');
  }

  static Future<void> logout() async {
    await _client
        .post(
          _base.replace(path: '/api/users/logout'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<TicketEntity> getTicket(String ticketId) async {
    final response = await _client
        .get(
          _base.replace(path: '/api/tickets/$ticketId'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }
    throw Exception(body['message'] ?? 'Ticket no encontrado');
  }

  static Future<List<LunchEntity>> getLunches() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/lunches'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return (body as List)
          .map((e) => LunchEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener almuerzos');
  }

  static Future<List<TicketEntity>> getAllTickets() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/tickets/all'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return (body as List)
          .map((e) => TicketEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener todos los tickets');
  }

  static Future<List<TicketEntity>> getTickets() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/tickets'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return (body as List)
          .map((e) => TicketEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener tickets');
  }

  static Future<TicketEntity> buyTicket(int lunchId) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/tickets/buy'),
          headers: _headers(auth: true),
          body: jsonEncode({'lunch_id': lunchId}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }
    throw Exception(body['message'] ?? 'Error al comprar ticket');
  }

  static Future<TicketEntity> validateTicket(String ticketId) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/tickets/validate/$ticketId'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return TicketEntity.fromJson(body as Map<String, dynamic>);
    }
    throw Exception(body['message'] ?? 'Error al validar ticket');
  }

  static Future<List<Map<String, dynamic>>> getRecharges() async {
    final response = await _client
        .get(
          _base.replace(path: '/api/recharges'),
          headers: _headers(auth: true),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return (body as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener recargas');
  }

  static Future<Map<String, dynamic>> buyCredits(double value) async {
    final response = await _client
        .post(
          _base.replace(path: '/api/recharges/buy'),
          headers: _headers(auth: true),
          body: jsonEncode({'value': value}),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return body as Map<String, dynamic>;
    }
    throw Exception(body['message'] ?? 'Error al recargar saldo');
  }
}
