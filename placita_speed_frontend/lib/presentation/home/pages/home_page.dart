import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

/// Página de inicio (Home) - Después del login
/// Pantalla temporal para demostrar la navegación
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Container(
        // Fondo azul degradado completo
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.darkBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de construcción
                Icon(
                  Icons.construction,
                  size: 80,
                  color: AppTheme.white,
                ),
                const SizedBox(height: 24),
                // Título
                Text(
                  'En Construcción',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // Descripción
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Esta sección está siendo desarrollada. Pronto podrás comprar tus almuerzos aquí.',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                // Botón de logout
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
