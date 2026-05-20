import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/presentation/home/pages/admin_home_page.dart';
import 'package:placita_speed_frontend/presentation/home/pages/home_page.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/logo_widget.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/login_form.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

enum LoginAccessMode { student, admin }

extension LoginAccessModeLabel on LoginAccessMode {
  String get label => switch (this) {
    LoginAccessMode.student => 'Estudiante',
    LoginAccessMode.admin => 'Administrador',
  };

  String get actionLabel => switch (this) {
    LoginAccessMode.student => 'Acceso estudiante',
    LoginAccessMode.admin => 'Acceso administrador',
  };

  LoginAccessMode get alternate => switch (this) {
    LoginAccessMode.student => LoginAccessMode.admin,
    LoginAccessMode.admin => LoginAccessMode.student,
  };
}

/// Página de Login
/// Capa de Presentación - Organiza la interfaz de autenticación
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginAccessMode _accessMode = LoginAccessMode.student;

  void _onCredentialsChanged(String email, String password) {
    // Validación adicional con la contraseña será implementada con state management
  }

  void _onLoginPressed(BuildContext context) {
    final Widget targetPage = switch (_accessMode) {
      LoginAccessMode.student => const HomePage(),
      LoginAccessMode.admin => const AdminHomePage(),
    };

    // Validación exitosa - Navegar a la vista correspondiente
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => targetPage));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
        children: [
          Container(
            // Fondo azul degradado completo
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
              ),
            ),
            child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: _AccessModeToggle(
                label: _accessMode.actionLabel,
                onPressed: () {
                  setState(() {
                    _accessMode = _accessMode.alternate;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para versión móvil
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              // Logo y nombre de la app
              Expanded(
                flex: 2,
                child: Center(child: LogoWidget(logoSize: 100)),
              ),
              // Formulario de login
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: LoginFormWidget(
                    accessModeLabel: _accessMode.label,
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
          Expanded(flex: 1, child: Center(child: LogoWidget(logoSize: 150))),
          // Lado derecho: Formulario
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: LoginFormWidget(
                    accessModeLabel: _accessMode.label,
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

class _AccessModeToggle extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AccessModeToggle({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(28),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withAlpha(70), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
