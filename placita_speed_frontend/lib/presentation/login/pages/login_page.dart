import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/presentation/home/pages/home_page.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/logo_widget.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/login_form.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

/// Página de Login
/// Capa de Presentación - Organiza la interfaz de autenticación
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onCredentialsChanged(String email, String password) {
    // Validación adicional con la contraseña será implementada con state management
  }

  void _onLoginPressed(BuildContext context) {
    // Validación exitosa - Navegar a HomePage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

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
        child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
      ),
    );
  }

  /// Layout para versión móvil
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              // Logo y nombre de la app
              Expanded(
                flex: 2,
                child: Center(
                  child: LogoWidget(logoSize: 100),
                ),
              ),
              // Formulario de login
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: LoginFormWidget(
                    onLoginPressed: _onLoginPressed,
                    onCredentialsChanged: _onCredentialsChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Layout para versión web
  Widget _buildWebLayout() {
    return SafeArea(
      child: Row(
        children: [
          // Lado izquierdo: Logo
          Expanded(
            flex: 1,
            child: Center(
              child: LogoWidget(logoSize: 150),
            ),
          ),
          // Lado derecho: Formulario
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: LoginFormWidget(
                    onLoginPressed: _onLoginPressed,
                    onCredentialsChanged: _onCredentialsChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
