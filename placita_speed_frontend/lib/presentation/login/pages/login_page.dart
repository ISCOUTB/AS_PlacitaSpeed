import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/presentation/home/pages/admin_home_page.dart';
import 'package:placita_speed_frontend/presentation/home/pages/student_home_page.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/logo_widget.dart';
import 'package:placita_speed_frontend/presentation/login/widgets/login_form.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _onLoginPressed(
    BuildContext context,
    String email,
    String password,
  ) async {
    final user = await AppConfig().authRepository.login(email, password);

    if (user.userType != 'student' && user.userType != 'admin') {
      await AppConfig().authRepository.logout();
      throw Exception('Las credenciales no tienen un rol válido para acceder');
    }

    if (!context.mounted) return;

    final targetPage = user.userType == 'admin'
        ? const AdminHomePage()
        : const StudentHomePage();

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
