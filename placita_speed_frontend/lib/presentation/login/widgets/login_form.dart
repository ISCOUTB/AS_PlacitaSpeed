import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

/// Helper function para crear colores con opacidad de forma segura
Color _withOpacity(Color color, double opacity) {
  return color.withAlpha((opacity * 255).toInt());
}

/// Widget del formulario de login
/// Componente de presentación que contiene los campos de entrada
class LoginFormWidget extends StatefulWidget {
  final Function(BuildContext) onLoginPressed;
  final void Function(String email, String password) onCredentialsChanged;

  const LoginFormWidget({
    super.key,
    required this.onLoginPressed,
    required this.onCredentialsChanged,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    widget.onCredentialsChanged(
      _emailController.text,
      _passwordController.text,
    );
    // Simular delay de request
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoginPressed(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24.0 : 48.0,
          vertical: 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de email
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Correo electrónico',
                hintStyle: TextStyle(
                  color: _withOpacity(AppTheme.white, 0.6),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: _withOpacity(AppTheme.white, 0.8),
                ),
                filled: true,
                fillColor: _withOpacity(AppTheme.white, 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _withOpacity(AppTheme.white, 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _withOpacity(AppTheme.white, 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.white,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Campo de contraseña
            TextField(
              controller: _passwordController,
              enabled: !_isLoading,
              obscureText: _obscurePassword,
              style: const TextStyle(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Contraseña',
                hintStyle: TextStyle(
                  color: _withOpacity(AppTheme.white, 0.6),
                ),
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: _withOpacity(AppTheme.white, 0.8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _withOpacity(AppTheme.white, 0.8),
                  ),
                  onPressed: !_isLoading
                      ? () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        }
                      : null,
                ),
                filled: true,
                fillColor: _withOpacity(AppTheme.white, 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _withOpacity(AppTheme.white, 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _withOpacity(AppTheme.white, 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.white,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botón de login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !_isLoading ? _handleLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: _withOpacity(AppTheme.white, 0.6),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _withOpacity(AppTheme.primaryBlue, 0.7),
                          ),
                        ),
                      )
                    : Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
              ),
            ),
            // Nota: El registro no está disponible. Solo usuarios con correo institucional
            // de la Universidad Tecnológica de Bolívar pueden acceder a la aplicación.
          ],
        ),
      ),
    );
  }
}
