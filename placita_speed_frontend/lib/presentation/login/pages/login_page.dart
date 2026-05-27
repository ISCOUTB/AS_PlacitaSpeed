import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/config/api_config.dart';
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
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = ApiConfig.baseUrl;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  void _setApiUrl() {
    final newUrl = _apiUrlController.text.trim();
    if (newUrl.isEmpty) return;

    ApiConfig.setBaseUrl(newUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('API URL establecida en $newUrl')));
    setState(() {});
  }

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

    final targetPage =
        user.userType == 'admin'
            ? AdminHomePage(user: user)
            : StudentHomePage(user: user);

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => targetPage));
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
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              _buildApiUrlEditor(),
              Expanded(
                flex: 2,
                child: Center(child: LogoWidget(logoSize: 100)),
              ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: LoginFormWidget(onLoginPressed: _onLoginPressed),
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
                  child: Column(
                    children: [
                      _buildApiUrlEditor(),
                      LoginFormWidget(onLoginPressed: _onLoginPressed),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiUrlEditor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servidor API',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiUrlController,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: AppTheme.white),
            decoration: InputDecoration(
              hintText: 'http://192.168.x.x:3000',
              hintStyle: TextStyle(color: AppTheme.white.withOpacity(0.7)),
              filled: true,
              fillColor: AppTheme.white.withOpacity(0.12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _setApiUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Usar dirección API'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
