import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

Color _withOpacity(Color color, double opacity) {
  return color.withAlpha((opacity * 255).toInt());
}

class LogoWidget extends StatelessWidget {
  final double logoSize;

  const LogoWidget({super.key, this.logoSize = 120.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _withOpacity(AppTheme.white, 0.95),
            boxShadow: [
              BoxShadow(
                color: _withOpacity(Colors.black, 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'UTB',
              style: TextStyle(
                fontSize: logoSize * 0.4,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: logoSize * 0.3),
        Text(
          'placita speed',
          style: AppTheme.logoNameStyle.copyWith(
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
