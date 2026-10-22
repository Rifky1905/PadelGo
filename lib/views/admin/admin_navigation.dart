import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_pricing_screen.dart';
import 'admin_qris_screen.dart';
import 'admin_schedule_screen.dart';

/// Shell navigasi admin — NavigationRail di layar lebar,
/// BottomNavigationBar di mobile.
class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Mode DB: muat pesanan, slot tutup, dan tarif dari Supabase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().loadAdminData();
    });
  }

  static const _pages = [
    AdminDashboardScreen(),
    AdminScheduleScreen(),
    AdminOrdersScreen(),
    AdminPricingScreen(),
    AdminQrisScreen(),
  ];

  static const _destinations = [
    (icon: Icons.dashboard_outlined, active: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.calendar_month_outlined, active: Icons.calendar_month, label: 'Jadwal'),
    (icon: Icons.receipt_long_outlined, active: Icons.receipt_long, label: 'Pesanan'),
    (icon: Icons.price_change_outlined, active: Icons.price_change, label: 'Harga'),
    (icon: Icons.qr_code_2_outlined, active: Icons.qr_code_2, label: 'QRIS'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final body = Column(
      children: [
        const _AdminTopBar(),
        Expanded(child: _pages[_index]),
      ],
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme:
                  const IconThemeData(color: PadelGoColors.primary),
              selectedLabelTextStyle: const TextStyle(
                color: PadelGoColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedIconTheme:
                  const IconThemeData(color: PadelGoColors.textHint),
              unselectedLabelTextStyle: const TextStyle(
                color: PadelGoColors.textHint,
                fontSize: 12,
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.active),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, color: PadelGoColors.divider),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          for (final d in _destinations)
            BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.active),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

/// Top bar admin: judul, badge Admin, dan tombol logout.
class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: PadelGoColors.divider)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: PadelGoColors.pinkGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_tennis,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PadelGo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.name ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PadelGoColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PadelGoColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: PadelGoColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Keluar',
                icon: const Icon(Icons.logout_rounded, size: 21),
                color: PadelGoColors.textSecondary,
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
