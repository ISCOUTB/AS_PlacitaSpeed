import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/presentation/login/pages/login_page.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

void main() {
  // Inicializar configuración de la aplicación
  AppConfig();
  runApp(const PlacitaSpeedApp());
}

/// Aplicación principal de Placita Speed
/// Capa de Presentación - Punto de entrada
class PlacitaSpeedApp extends StatelessWidget {
  const PlacitaSpeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Placita Speed',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
