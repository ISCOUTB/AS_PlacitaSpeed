import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

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

  final List<_PaymentReviewItem> _payments = [
    _PaymentReviewItem(
      studentName: 'María Gómez',
      reference: '#PS-2041',
      amount: '12.000',
      status: 'Pendiente',
    ),
    _PaymentReviewItem(
      studentName: 'Juan Pérez',
      reference: '#PS-2042',
      amount: '13.000',
      status: 'Verificar',
    ),
    _PaymentReviewItem(
      studentName: 'Laura Díaz',
      reference: '#PS-2043',
      amount: '11.500',
      status: 'Confirmado',
    ),
  ];

  int get _totalStock =>
      _inventory.fold<int>(0, (sum, item) => sum + item.stock);

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

  void _markPaymentVerified(int index) {
    setState(() {
      _payments[index].status = 'Verificado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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
                    childAspectRatio: 1.7,
                    children: const [
                      _SummaryCard(
                        title: 'Stock total',
                        value: '68',
                        icon: Icons.inventory_2_outlined,
                        accentColor: Color(0xFF0052CC),
                      ),
                      _SummaryCard(
                        title: 'Pagos pendientes',
                        value: '2',
                        icon: Icons.receipt_long_outlined,
                        accentColor: Color(0xFFF59E0B),
                      ),
                      _SummaryCard(
                        title: 'Verificados hoy',
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
                    title: 'Verificación de pagos',
                    subtitle: 'Aprueba o revisa comprobantes pendientes',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList.separated(
                  itemCount: _payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return _PaymentReviewCard(
                      payment: payment,
                      onVerify: payment.status == 'Verificado'
                          ? null
                          : () => _markPaymentVerified(index),
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
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel administrativo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestiona inventario y revisa pagos sin salir de un mismo panel.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(214),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Stock activo',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '$totalStock',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
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

class _PaymentReviewCard extends StatelessWidget {
  final _PaymentReviewItem payment;
  final VoidCallback? onVerify;

  const _PaymentReviewCard({required this.payment, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final isVerified = payment.status == 'Verificado';

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
            child: const Icon(Icons.receipt_outlined, color: Color(0xFF0052CC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.reference} · COP ${payment.amount}',
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
                      (isVerified
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withAlpha(24),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payment.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isVerified
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF0052CC),
                    foregroundColor: isVerified
                        ? const Color(0xFF334155)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isVerified ? 'Listo' : 'Verificar'),
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

class _PaymentReviewItem {
  final String studentName;
  final String reference;
  final String amount;
  String status;

  _PaymentReviewItem({
    required this.studentName,
    required this.reference,
    required this.amount,
    required this.status,
  });
}
