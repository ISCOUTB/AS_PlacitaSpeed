import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:placita_speed_frontend/infrastructure/services/api_service.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

enum _ScanState { scanning, processing, success, error }

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  _ScanState _state = _ScanState.scanning;
  TicketEntity? _ticket;
  String? _errorMessage;
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _processing = true;
      _state = _ScanState.processing;
    });
    await _controller.stop();

    try {
      final ticket = await ApiService.useTicket(raw);
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _state = _ScanState.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _state = _ScanState.error;
        });
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _state = _ScanState.scanning;
      _ticket = null;
      _errorMessage = null;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_state == _ScanState.scanning || _state == _ScanState.processing)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

          if (_state == _ScanState.scanning)
            _ScanOverlay(),

          if (_state != _ScanState.scanning)
            _ResultPanel(
              state: _state,
              ticket: _ticket,
              errorMessage: _errorMessage,
              onScanAgain: _scanAgain,
              onClose: () => Navigator.of(context).pop(),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Escanear ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(color: Colors.black54),
        ),
        Row(
          children: [
            Expanded(child: Container(color: Colors.black54)),
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lightBlue, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Expanded(child: Container(color: Colors.black54)),
          ],
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black54,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 24),
            child: const Text(
              'Apunta al código QR del estudiante',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final _ScanState state;
  final TicketEntity? ticket;
  final String? errorMessage;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  const _ResultPanel({
    required this.state,
    required this.ticket,
    required this.errorMessage,
    required this.onScanAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: switch (state) {
        _ScanState.processing => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Verificando ticket...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        _ScanState.success => _SuccessContent(
            ticket: ticket!,
            onScanAgain: onScanAgain,
            onClose: onClose,
          ),
        _ScanState.error => _ErrorContent(
            message: errorMessage ?? 'Error desconocido',
            onScanAgain: onScanAgain,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _SuccessContent extends StatelessWidget {
  final TicketEntity ticket;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  const _SuccessContent({
    required this.ticket,
    required this.onScanAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Ticket válido!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.lunchName,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.userEmail,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScanAgain,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Otro ticket'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cerrar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onScanAgain;

  const _ErrorContent({required this.message, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_rounded,
              color: Colors.red,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ticket inválido',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onScanAgain,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Intentar de nuevo'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
