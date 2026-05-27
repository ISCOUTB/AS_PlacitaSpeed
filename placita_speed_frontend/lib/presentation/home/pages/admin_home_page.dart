import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/infrastructure/services/api_service.dart';
import 'package:placita_speed_frontend/presentation/login/pages/login_page.dart';
import 'package:placita_speed_frontend/presentation/scanner/pages/qr_scanner_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _summarySectionKey = GlobalKey();
  final GlobalKey _inventorySectionKey = GlobalKey();
  final GlobalKey _ordersSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<_InventoryControlItem> _inventory = [];
  List<_OrderItem> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final lunches = await ApiService.getLunches();
      final inv = <_InventoryControlItem>[];
      final total = lunches.fold<int>(0, (s, e) => s + e.stock);
      inv.add(_InventoryControlItem(name: 'Almuerzos del día', stock: total, unit: 'u'));
      inv.add(_InventoryControlItem(name: 'Complementos', stock: 0, unit: 'u'));
      inv.add(_InventoryControlItem(name: 'Bebidas', stock: 0, unit: 'u'));
      inv.add(_InventoryControlItem(name: 'Postres', stock: 0, unit: 'u'));

      // Orders: placeholder until admin tickets endpoint exists
      final orders = <_OrderItem>[];

      setState(() {
        _inventory = inv;
        _orders = orders;
      });
    } catch (e) {
      // ignore errors — keep defaults
    }
  }

  // initial orders left empty; admin orders endpoint not present yet

  int get _totalStock => _inventory.fold<int>(0, (sum, item) => sum + item.stock);

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

  void _toggleOrderStatus(int index) {
    setState(() {
      _orders[index].status = _orders[index].status == 'Entregado'
          ? 'Pendiente'
          : 'Entregado';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    _scaffoldKey.currentState?.closeDrawer();
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final currentContext = key.currentContext;
      if (currentContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        currentContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    });
  }

  void _openScanner() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
  }

  Future<void> _logout() async {
    await AppConfig().authRepository.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7FB),
      drawer: _AdminDrawer(
        onSummaryTap: () => _scrollToSection(_summarySectionKey),
        onInventoryTap: () => _scrollToSection(_inventorySectionKey),
        onOrdersTap: () => _scrollToSection(_ordersSectionKey),
        onScannerTap: _openScanner,
        onLogoutTap: _logout,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
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
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: _AdminHeader(
                    totalStock: _totalStock,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onLogoutTap: _logout,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    key: _summarySectionKey,
                    child: GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width >= 900
                          ? 4
                          : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: const [
                        _SummaryCard(
                          title: 'Stock total',
                          value: '68',
                          icon: Icons.inventory_2_outlined,
                          accentColor: Color(0xFF0052CC),
                        ),
                        _SummaryCard(
                          title: 'Pedidos pendientes',
                          value: '2',
                          icon: Icons.receipt_long_outlined,
                          accentColor: Color(0xFFF59E0B),
                        ),
                        _SummaryCard(
                          title: 'Entregados hoy',
                          value: '1',
                          icon: Icons.verified_outlined,
                          accentColor: Color(0xFF10B981),
                        ),
                        _SummaryCard(
                          title: 'Alertas',
                          value: '0',
                          icon: Icons.warning_amber_rounded,
                          accentColor: Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    key: _inventorySectionKey,
                    child: const _SectionHeader(
                      title: 'Inventario',
                      subtitle: 'Manipula stock en tiempo real',
                    ),
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
                  child: Container(
                    key: _ordersSectionKey,
                    child: const _SectionHeader(
                      title: 'Pedidos pendientes',
                      subtitle:
                          'Lista de pedidos sin entregar; marca como entregado al entregar en mostrador',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _OrderCard(
                      order: order,
                      onToggle: () => _toggleOrderStatus(index),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalStock;
  final VoidCallback onMenuTap;
  final Future<void> Function() onLogoutTap;

  const _AdminHeader({
    required this.totalStock,
    required this.onMenuTap,
    required this.onLogoutTap,
  });

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
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                tooltip: 'Abrir menú',
              ),
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
                  onPressed: () => onLogoutTap(),
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

class _AdminDrawer extends StatelessWidget {
  final VoidCallback onSummaryTap;
  final VoidCallback onInventoryTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onScannerTap;
  final Future<void> Function() onLogoutTap;

  const _AdminDrawer({
    required this.onSummaryTap,
    required this.onInventoryTap,
    required this.onOrdersTap,
    required this.onScannerTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F8FC),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0052CC), Color(0xFF003399)],
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel administrativo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Navegación y control',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Resumen',
              onTap: onSummaryTap,
            ),
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              label: 'Inventario',
              onTap: onInventoryTap,
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'Pedidos',
              onTap: onOrdersTap,
            ),
            _DrawerItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Escanear QR',
              onTap: onScannerTap,
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              onTap: () {
                Navigator.of(context).pop();
                onLogoutTap();
              },
              destructive: true,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? const Color(0xFFC0392B)
        : const Color(0xFF1B1B1B);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
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

class _OrderCard extends StatelessWidget {
  final _OrderItem order;
  final VoidCallback? onToggle;

  const _OrderCard({required this.order, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == 'Entregado';

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
              Icons.shopping_bag_outlined,
              color: Color(0xFF0052CC),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.orderRef} · ${order.details}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (isDelivered
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withAlpha(24),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDelivered
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDelivered
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF0052CC),
                    foregroundColor: isDelivered
                        ? const Color(0xFF334155)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isDelivered ? 'Marcar pendiente' : 'Entregar'),
                ),
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

class _OrderItem {
  final String customerName;
  final String orderRef;
  final String details;
  String status;

  _OrderItem({
    required this.customerName,
    required this.orderRef,
    required this.details,
    required this.status,
  });
}
