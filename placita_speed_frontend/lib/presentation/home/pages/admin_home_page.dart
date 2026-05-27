import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/domain/entities/ticket_entity.dart';
import 'package:placita_speed_frontend/domain/entities/user_entity.dart';
import 'package:placita_speed_frontend/infrastructure/services/api_service.dart';
import 'package:placita_speed_frontend/presentation/login/pages/login_page.dart';
import 'package:placita_speed_frontend/presentation/scanner/pages/qr_scanner_page.dart';

class AdminHomePage extends StatefulWidget {
  final UserEntity user;

  const AdminHomePage({super.key, required this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<_InventoryControlItem> _inventory = [
    _InventoryControlItem(name: 'Almuerzos del día', stock: 22, unit: 'u'),
    _InventoryControlItem(name: 'Complementos', stock: 14, unit: 'u'),
    _InventoryControlItem(name: 'Bebidas', stock: 22, unit: 'u'),
    _InventoryControlItem(name: 'Postres', stock: 10, unit: 'u'),
  ];

  List<TicketEntity> _tickets = [];

  int get _totalStock =>
      _inventory.fold<int>(0, (sum, item) => sum + item.stock);

  int get _pendingCount =>
      _tickets.where((t) => t.state == 'NO_USED').length;

  int get _deliveredCount =>
      _tickets.where((t) => t.state == 'USED').length;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final tickets = await ApiService.getAllTickets();
      if (mounted) setState(() => _tickets = tickets);
    } catch (_) {}
  }

  void _incrementStock(int index) {
    setState(() {
      _inventory[index].stock++;
    });
  }

  void _decrementStock(int index) {
    if (_inventory[index].stock == 0) {
      return;
    }

    setState(() {
      _inventory[index].stock--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QrScannerPage()),
        ),
        backgroundColor: const Color(0xFF0052CC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text(
          'Escanear QR',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F7FB), Color(0xFFEFF3FF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _loadTickets,
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: _AdminHeader(totalStock: _totalStock),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width >= 900
                        ? 4
                        : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _SummaryCard(
                        title: 'Stock total',
                        value: '$_totalStock',
                        icon: Icons.inventory_2_outlined,
                        accentColor: const Color(0xFF0052CC),
                      ),
                      _SummaryCard(
                        title: 'Pedidos pendientes',
                        value: '$_pendingCount',
                        icon: Icons.receipt_long_outlined,
                        accentColor: const Color(0xFFF59E0B),
                      ),
                      _SummaryCard(
                        title: 'Entregados hoy',
                        value: '$_deliveredCount',
                        icon: Icons.verified_outlined,
                        accentColor: const Color(0xFF10B981),
                      ),
                      _SummaryCard(
                        title: 'Total tickets',
                        value: '${_tickets.length}',
                        icon: Icons.confirmation_number_outlined,
                        accentColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Inventario',
                    subtitle: 'Manipula stock en tiempo real',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: _inventory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _inventory[index];
                    return _InventoryControlCard(
                      item: item,
                      onIncrease: () => _incrementStock(index),
                      onDecrease: () => _decrementStock(index),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Pedidos pendientes',
                    subtitle:
                        'Lista de pedidos sin entregar; marca como entregado al entregar en mostrador',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: _tickets.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No hay pedidos registrados',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: _tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return _TicketCard(ticket: ticket);
                        },
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalStock;

  const _AdminHeader({required this.totalStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052CC), Color(0xFF003399)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Panel administrativo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Material(
                color: Colors.white.withAlpha(24),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  tooltip: 'Cerrar sesión',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestiona inventario y pedidos',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 13,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Stock activo',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    '$totalStock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryControlCard extends StatelessWidget {
  final _InventoryControlItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _InventoryControlCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unidades disponibles',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ActionChip(
                icon: Icons.remove,
                color: const Color(0xFFEF4444),
                onTap: onDecrease,
              ),
              const SizedBox(width: 10),
              Container(
                width: 58,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${item.stock}${item.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ActionChip(
                icon: Icons.add,
                color: const Color(0xFF10B981),
                onTap: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketEntity ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isUsed = ticket.state == 'USED';
    final isPending = ticket.state == 'NO_USED';
    final color = isUsed
        ? const Color(0xFF10B981)
        : isPending
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final label = isUsed ? 'Entregado' : isPending ? 'Pendiente' : 'Expirado';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0052CC).withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFF0052CC),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.userEmail,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ticket.lunchName} · ${ticket.ticketId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryControlItem {
  final String name;
  final String unit;
  int stock;

  _InventoryControlItem({
    required this.name,
    required this.stock,
    required this.unit,
  });
}
