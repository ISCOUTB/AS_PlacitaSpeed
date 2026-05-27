import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/presentation/home/pages/admin_home_page.dart';
import 'package:placita_speed_frontend/presentation/home/pages/student_home_page.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginAccessMode _accessMode = LoginAccessMode.student;

  Future<void> _onLoginPressed(
    BuildContext context,
    String email,
    String password,
  ) async {
    final user = await AppConfig().authRepository.login(email, password);

    final matchesSelectedAccess = switch (_accessMode) {
      LoginAccessMode.student => user.userType == 'student',
      LoginAccessMode.admin => user.userType == 'admin',
    };

    if (!matchesSelectedAccess) {
      await AppConfig().authRepository.logout();
      throw Exception('El acceso seleccionado no coincide con tu rol');
    }

    if (!context.mounted) return;

    final targetPage = user.userType == 'admin'
        ? AdminHomePage(user: user)
        : StudentHomePage(user: user);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                  setState(() => _accessMode = _accessMode.alternate);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(child: LogoWidget(logoSize: 100)),
              ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: LoginFormWidget(
                    accessModeLabel: _accessMode.label,
                    onLoginPressed: _onLoginPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(flex: 1, child: Center(child: LogoWidget(logoSize: 150))),
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: LoginFormWidget(
                    accessModeLabel: _accessMode.label,
                    onLoginPressed: _onLoginPressed,
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
              const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white),
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
