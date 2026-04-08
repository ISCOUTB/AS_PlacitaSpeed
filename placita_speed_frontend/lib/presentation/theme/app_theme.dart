import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales de Placita Speed
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color darkBlue = Color(0xFF003399);
  static const Color lightBlue = Color(0xFF3366FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF666666);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: primaryBlue,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      elevation: 0,
      centerTitle: true,
    ),
  );

  // Estilos de texto reutilizables
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: white,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: white,
  );

  static const TextStyle logoNameStyle = TextStyle(
    fontSize: 18,
    fontStyle: FontStyle.italic,
    color: white,
    fontWeight: FontWeight.w300,
  );
}
