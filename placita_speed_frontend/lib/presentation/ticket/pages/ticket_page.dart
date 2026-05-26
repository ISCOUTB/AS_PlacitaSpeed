import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

class TicketPage extends StatelessWidget {
  final TicketEntity ticket;

  const TicketPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _QrCard(ticket: ticket),
                    const SizedBox(height: 16),
                    _DetailsCard(ticket: ticket),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        ),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Volver al inicio'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Muestra el QR en el mostrador',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.confirmation_number_rounded,
            color: Colors.white70,
            size: 32,
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final TicketEntity ticket;
  const _QrCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withAlpha(20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _StateBadge(state: ticket.state),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: ticket.ticketId,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.transparent,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppTheme.primaryBlue,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppTheme.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ticket.ticketId.substring(0, 8).toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final TicketEntity ticket;
  const _DetailsCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final date = ticket.createdAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE5FF)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.restaurant_rounded,
            label: 'Almuerzo',
            value: ticket.lunchName,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Precio',
            value:
                '\$${ticket.lunchPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Fecha',
            value: dateStr,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'Estudiante',
            value: ticket.userEmail,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String state;
  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (state) {
      'USED' => (Colors.grey, 'Ya utilizado', Icons.check_circle_outline),
      'EXPIRED' => (Colors.red, 'Expirado', Icons.cancel_outlined),
      _ => (
          const Color(0xFF10B981),
          'Válido — listo para canjear',
          Icons.verified_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
