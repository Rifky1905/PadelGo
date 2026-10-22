import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'admin_orders_screen.dart';
import 'revenue_detail_screen.dart';
import 'today_bookings_screen.dart';

/// Dashboard admin — kartu statistik ringkas + pesanan terbaru.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final recent = admin.orders.take(4).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ringkasan operasional PadelGo hari ini.',
          style: TextStyle(fontSize: 13.5, color: PadelGoColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // Kartu statistik
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 720 ? 3 : 1;
            final stats = [
              _Stat(
                icon: Icons.payments_outlined,
                value: Formatters.rupiah(admin.totalRevenue),
                label: 'Total Pendapatan',
                color: PadelGoColors.primary,
                onTap: () => _open(context, const RevenueDetailScreen()),
              ),
              _Stat(
                icon: Icons.event_available_outlined,
                value: '${admin.todayBookings}',
                label: 'Booking Hari Ini',
                color: const Color(0xFF1E88E5),
                onTap: () => _open(context, const TodayBookingsScreen()),
              ),
              _Stat(
                icon: Icons.sports_tennis,
                value: '${admin.activeCourts}',
                label: 'Lapangan Aktif',
                color: const Color(0xFF2E9E62),
              ),
            ];
            if (cols == 3) {
              return Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: _StatCard(stat: stats[i])),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (final s in stats)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StatCard(stat: s),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),

        // Info pending
        if (admin.pendingOrders > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PadelGoColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notification_important_outlined,
                  color: PadelGoColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${admin.pendingOrders} pesanan menunggu validasi pembayaran.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PadelGoColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        const Text(
          'Pesanan Terbaru',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: PadelGoColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        for (final order in recent) AdminOrderCard(order: order, compact: true),
      ],
    );
  }

  static void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class _Stat {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: PadelGoColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: stat.onTap,
          splashColor: stat.color.withValues(alpha: 0.08),
          hoverColor: stat.color.withValues(alpha: 0.04),
          child: Padding(padding: const EdgeInsets.all(18), child: _content()),
        ),
      ),
    );
  }

  Widget _content() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: stat.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(stat.icon, color: stat.color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: PadelGoColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (stat.onTap != null)
          Icon(
            Icons.chevron_right_rounded,
            color: stat.color.withValues(alpha: 0.7),
          ),
      ],
    );
  }
}
