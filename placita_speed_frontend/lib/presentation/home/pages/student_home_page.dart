import 'package:flutter/material.dart';
import 'package:placita_speed_frontend/config/app_config.dart';
import 'package:placita_speed_frontend/infrastructure/services/api_service.dart';
import 'package:placita_speed_frontend/presentation/login/pages/login_page.dart';
import 'package:placita_speed_frontend/presentation/ticket/pages/ticket_page.dart';
import 'package:placita_speed_frontend/presentation/theme/app_theme.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<_WeeklyMenuItem> _weeklyMenu = [];
  List<_InventoryItem> _todayInventory = [];
  String _userName = 'Usuario';
  String _balance = '0';
  String _dailyTitle = 'Menú del día';
  String _dailySubtitle = '';
  String _dailyPrice = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AppConfig().authRepository.getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.name;
          _balance = _formatCurrency(user.virtualBalance);
        });
      }

      final lunches = await ApiService.getLunches();

      // Build weekly menu from available lunches (take up to 5)
      final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
      final weekly = <_WeeklyMenuItem>[];
      for (var i = 0; i < lunches.length && i < 5; i++) {
        final l = lunches[i];
        weekly.add(_WeeklyMenuItem(
          day: days[i],
          lunch: l.description.isNotEmpty
              ? '${l.name}\n${l.description}'
              : l.name,
          price: _formatCurrency(l.virtualPrice),
        ));
      }

      // Daily menu: use first lunch if exists
      if (lunches.isNotEmpty) {
        final d = lunches.first;
        _dailyTitle = d.name;
        _dailySubtitle = d.description;
        _dailyPrice = _formatCurrency(d.virtualPrice);
      }

      final totalLunchStock = lunches.fold<int>(0, (s, e) => s + e.stock);

      setState(() {
        _weeklyMenu = weekly;
        _todayInventory = [
          _InventoryItem(name: 'Almuerzos del día', units: '$totalLunchStock unidades disponibles'),
          _InventoryItem(name: 'Complementos', units: '0 unidades disponibles'),
          _InventoryItem(name: 'Bebidas', units: '0 unidades disponibles'),
        ];
      });
    } catch (e) {
      // Silently fail; mantenemos valores por defecto
    }
  }

  String _formatCurrency(double value) {
    final intVal = value.round();
    final s = intVal.toString();
    var result = '';
    var count = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      result = '${s[i]}$result';
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return result;
  }

  final List<_TimelineItem> _todayTimeline = const [
    _TimelineItem(
      time: '08:00',
      title: 'Apertura de inventario',
      detail: 'Se habilitan los productos del día',
      highlighted: false,
    ),
    _TimelineItem(
      time: '12:00',
      title: 'Menú del día activo',
      detail: 'Compra prioritaria para estudiantes',
      highlighted: true,
    ),
    _TimelineItem(
      time: '14:30',
      title: 'Cierre de reservas',
      detail: 'Se bloquean los cupos restantes',
      highlighted: false,
    ),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  Future<void> _handleOrder(BuildContext context) async {
    try {
      final ticket = await ApiService.createTicket(
        lunchId: 1,
      );
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TicketPage(ticket: ticket)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _logout(BuildContext context) async {
    await AppConfig().authRepository.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _StudentDrawer(
        onHomeTap: () => _onDrawerTabSelected(0),
        onOrderTap: () => _onDrawerTabSelected(1),
        onProfileTap: () => _onDrawerTabSelected(2),
        onHelpTap: () => _onDrawerTabSelected(2),
        onSettingsTap: () => _onDrawerTabSelected(2),
        onLogoutTap: () => _logout(context),
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FB), Color(0xFFF3F4FF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _OverviewSection(
                weeklyMenu: _weeklyMenu,
                onMenuTap: _openDrawer,
                onLogout: () => _logout(context),
                userName: _userName,
                balance: _balance,
              ),
              _OrderSection(
                timeline: _todayTimeline,
                inventory: _todayInventory,
                onMenuTap: _openDrawer,
                onOrder: _handleOrder,
                balance: _balance,
                dailyTitle: _dailyTitle,
                dailySubtitle: _dailySubtitle,
                dailyPrice: _dailyPrice,
              ),
              _ProfileSection(
                onMenuTap: _openDrawer,
                onLogout: () => _logout(context),
                name: _userName,
                balance: _balance,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _StudentBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final List<_WeeklyMenuItem> weeklyMenu;
  final VoidCallback onMenuTap;
  final VoidCallback onLogout;
  final String userName;
  final String balance;

  const _OverviewSection({
    required this.weeklyMenu,
    required this.onMenuTap,
    required this.onLogout,
    required this.userName,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
              child: _StudentHeader(
              title: 'Hola, $userName',
            subtitle: 'Consulta tu menú semanal y el inventario del día',
            actionIcon: Icons.menu_rounded,
            onActionTap: onMenuTap,
          ),
        ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(child: _BalanceCard(balance: balance)),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Menú de la semana',
              actionLabel: 'Ver todo',
              onActionTap: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          sliver: SliverList.separated(
            itemCount: weeklyMenu.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
              _WeeklyMenuCard(item: weeklyMenu[index]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _OrderSection extends StatelessWidget {
  final List<_TimelineItem> timeline;
  final List<_InventoryItem> inventory;
  final VoidCallback onMenuTap;
  final Future<void> Function(BuildContext) onOrder;
  final String balance;
  final String dailyTitle;
  final String dailySubtitle;
  final String dailyPrice;

  const _OrderSection({
    required this.timeline,
    required this.inventory,
    required this.onMenuTap,
    required this.onOrder,
    required this.balance,
    required this.dailyTitle,
    required this.dailySubtitle,
    required this.dailyPrice,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _StudentHeader(
            title: 'Ordenar',
            subtitle: 'Menú del día, inventario y estado de reservas',
            actionIcon: Icons.menu_rounded,
            onActionTap: onMenuTap,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          sliver: SliverToBoxAdapter(
            child: _OrderSummaryCard(
              title: 'Menú del día',
              description: 'Solo se muestra el inventario del día actual.',
              balance: balance,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Menú del día',
              actionLabel: 'Editar pedido',
              onActionTap: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          sliver: SliverToBoxAdapter(
            child: _DailyMenuCard(
              title: dailyTitle,
              subtitle: dailySubtitle,
              price: dailyPrice.isNotEmpty ? dailyPrice : '0',
              availability: 'Inventario del día actual',
              onOrder: onOrder,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Inventario disponible hoy',
              actionLabel: 'Ver stock',
              onActionTap: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          sliver: SliverList.separated(
            itemCount: inventory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _InventoryCard(item: inventory[index]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Estado del día',
              actionLabel: 'Detalles',
              onActionTap: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          sliver: SliverList.separated(
            itemCount: timeline.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _TimelineCard(item: timeline[index]),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onLogout;
  final String name;
  final String balance;

  const _ProfileSection({required this.onMenuTap, required this.onLogout, required this.name, required this.balance});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _StudentHeader(
            title: 'Perfil',
            subtitle: 'Información de tu cuenta de estudiante',
            actionIcon: Icons.menu_rounded,
            onActionTap: onMenuTap,
            showAvatar: true,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          sliver: SliverToBoxAdapter(
            child: _ProfileSummaryCard(
              name: name,
              balance: balance,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(
              title: 'Accesos rápidos',
              actionLabel: 'Configuración',
              onActionTap: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate.fixed(const [
              _QuickActionCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Saldo',
                subtitle: 'Ver y añadir saldo',
              ),
              _QuickActionCard(
                icon: Icons.storefront_rounded,
                title: 'Pedidos',
                subtitle: 'Historial y estado',
              ),
              _QuickActionCard(
                icon: Icons.headset_mic_rounded,
                title: 'Ayuda',
                subtitle: 'Soporte y preguntas',
              ),
              _QuickActionCard(
                icon: Icons.settings_rounded,
                title: 'Configuración',
                subtitle: 'Ajustes de cuenta',
              ),
            ]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 118,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverToBoxAdapter(
            child: FilledButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData actionIcon;
  final VoidCallback onActionTap;
  final bool showAvatar;

  const _StudentHeader({
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    required this.onActionTap,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAvatar)
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.white, width: 2),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF1F4FF), Color(0xFFD7E2FF)],
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryBlue,
                      size: 36,
                    ),
                  ),
                if (showAvatar) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.white.withAlpha(180),
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onActionTap,
                  icon: Icon(actionIcon, color: AppTheme.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFEAF0FF),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo actual',
                  style: TextStyle(
                    color: AppTheme.textGray.withAlpha(200),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  balance,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1B1B1B),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppTheme.lightBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyMenuCard extends StatelessWidget {
  final _WeeklyMenuItem item;

  const _WeeklyMenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE5FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFEAF0FF),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.day,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.lunch,
                  style: const TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.price,
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final _InventoryItem item;

  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFEAF0FF),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.units,
                  style: TextStyle(color: AppTheme.textGray.withAlpha(200)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final String title;
  final String description;
  final String balance;

  const _OrderSummaryCard({
    required this.title,
    required this.description,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withAlpha(40),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.white.withAlpha(34),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  balance,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.white.withAlpha(210),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStatTile(
                  icon: Icons.schedule_rounded,
                  label: 'Entrega',
                  value: '12:00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatTile(
                  icon: Icons.inventory_2_rounded,
                  label: 'Stock',
                  value: '22',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final String availability;
  final Future<void> Function(BuildContext) onOrder;

  const _DailyMenuCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.availability,
    required this.onOrder,
  });

  @override
  State<_DailyMenuCard> createState() => _DailyMenuCardState();
}

class _DailyMenuCardState extends State<_DailyMenuCard> {
  bool _isOrdering = false;

  Future<void> _handleOrder() async {
    setState(() => _isOrdering = true);
    await widget.onOrder(context);
    if (mounted) setState(() => _isOrdering = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8DEFF), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF1B1B1B),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: AppTheme.textGray.withAlpha(220),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                widget.price,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.availability,
                  style: const TextStyle(
                    color: Color(0xFF49A46C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isOrdering ? null : _handleOrder,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isOrdering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Ordenar ahora'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: Color(0xFFC9D6FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.add_shopping_cart_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1B1B1B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.textGray.withAlpha(210),
              fontSize: 12,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white.withAlpha(28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.white.withAlpha(210),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final _TimelineItem item;

  const _TimelineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accentColor = item.highlighted
        ? AppTheme.primaryBlue
        : AppTheme.textGray;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: item.highlighted ? const Color(0xFFF0F3FF) : AppTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: item.highlighted
              ? AppTheme.primaryBlue
              : const Color(0xFFE3E7F3),
          width: item.highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withAlpha(18),
            ),
            child: Icon(
              item.highlighted
                  ? Icons.play_arrow_rounded
                  : Icons.schedule_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: TextStyle(color: AppTheme.textGray.withAlpha(210)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.highlighted ? 'En curso' : 'Programado',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String name;
  final String balance;

  const _ProfileSummaryCard({
    required this.name,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFEAF0FF),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1B1B1B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileMetricTile(title: 'Saldo disponible', value: balance),
        ],
      ),
    );
  }
}

class _ProfileMetricTile extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileMetricTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.textGray.withAlpha(210),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _StudentBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Inicio',
              isActive: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: 'Ordenar',
              isActive: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              isActive: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryBlue : AppTheme.textGray;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentDrawer extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onOrderTap;
  final VoidCallback onProfileTap;
  final VoidCallback onHelpTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _StudentDrawer({
    required this.onHomeTap,
    required this.onOrderTap,
    required this.onProfileTap,
    required this.onHelpTap,
    required this.onSettingsTap,
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
                  colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.white,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fabian Andres Granados Moron',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'fgranados@utb.edu.co',
                          style: TextStyle(color: AppTheme.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Inicio',
              onTap: onHomeTap,
            ),
            _DrawerItem(
              icon: Icons.calendar_month_outlined,
              label: 'Ordenar',
              onTap: onOrderTap,
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              onTap: onProfileTap,
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Ayuda',
              onTap: onHelpTap,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: onSettingsTap,
            ),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              onTap: onLogoutTap,
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
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

class _WeeklyMenuItem {
  final String day;
  final String lunch;
  final String price;

  const _WeeklyMenuItem({
    required this.day,
    required this.lunch,
    required this.price,
  });
}

class _InventoryItem {
  final String name;
  final String units;

  const _InventoryItem({required this.name, required this.units});
}

class _TimelineItem {
  final String time;
  final String title;
  final String detail;
  final bool highlighted;

  const _TimelineItem({
    required this.time,
    required this.title,
    required this.detail,
    required this.highlighted,
  });
}
