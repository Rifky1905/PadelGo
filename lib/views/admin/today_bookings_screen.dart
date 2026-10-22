import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import 'admin_orders_screen.dart';

/// Daftar lengkap booking yang dijadwalkan main hari ini + aksi cepat.
class TodayBookingsScreen extends StatelessWidget {
  const TodayBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final orders = admin.todayOrders;
    final active = orders
        .where((o) => o.paymentStatus != OrderPaymentStatus.cancelled)
        .toList();
    final hours = active.fold(0, (s, o) => s + o.slotHours.length);
    final pending = orders
        .where((o) => o.paymentStatus == OrderPaymentStatus.pending)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Hari Ini')),
      body: RefreshIndicator(
        onRefresh: admin.loadAdminData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              Formatters.tanggalPanjang(DateTime.now()),
              style: const TextStyle(
                fontSize: 13.5,
                color: PadelGoColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryChip(
                  icon: Icons.event_available_outlined,
                  label: '${active.length} booking',
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  icon: Icons.schedule_outlined,
                  label: '$hours jam',
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  icon: Icons.hourglass_top_rounded,
                  label: '$pending menunggu',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 44,
                      color: PadelGoColors.textHint,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada booking untuk hari ini.',
                      style: TextStyle(color: PadelGoColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              for (final o in orders) _TodayBookingCard(order: o),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Flexible(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: PadelGoColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: PadelGoColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: PadelGoColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TodayBookingCard extends StatelessWidget {
  const _TodayBookingCard({required this.order});
  final AdminOrder order;

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    final (statusColor, statusBg) = switch (order.paymentStatus) {
      OrderPaymentStatus.pending => (
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      OrderPaymentStatus.paid => (
        PadelGoColors.available,
        PadelGoColors.availableBg,
      ),
      OrderPaymentStatus.completed => (
        const Color(0xFF2563EB),
        const Color(0xFFDBEAFE),
      ),
      OrderPaymentStatus.cancelled => (
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
      ),
    };
    final isPending = order.paymentStatus == OrderPaymentStatus.pending;
    final isPaid = order.paymentStatus == OrderPaymentStatus.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PadelGoColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blok jam
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: PadelGoColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        Formatters.jam(
                          order.slotHours.reduce((a, b) => a < b ? a : b),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PadelGoColors.primary,
                        ),
                      ),
                      Text(
                        '${order.slotHours.length} jam',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PadelGoColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _info(Icons.schedule_outlined, order.timeRange),
                      _info(Icons.sports_tennis, order.courtName),
                      _info(
                        Icons.confirmation_number_outlined,
                        '${order.id} • ${Formatters.rupiah(order.totalPrice)}',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.paymentStatus.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPending || isPaid || order.paymentProofUrl != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  if (order.paymentProofUrl != null)
                    IconButton(
                      tooltip: 'Lihat bukti pembayaran',
                      color: PadelGoColors.textSecondary,
                      icon: const Icon(Icons.receipt_outlined, size: 20),
                      onPressed: () => AdminOrderCard.showProof(
                        context,
                        order.paymentProofUrl!,
                      ),
                    ),
                  const Spacer(),
                  if (isPending || isPaid)
                    TextButton(
                      onPressed: () =>
                          AdminOrderCard.confirmCancel(context, order),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      child: const Text('Batalkan'),
                    ),
                  if (isPending)
                    FilledButton.icon(
                      onPressed: () => admin.confirmPayment(order.id),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Konfirmasi'),
                    ),
                  if (isPaid)
                    FilledButton.icon(
                      onPressed: () => admin.completeOrder(order.id),
                      icon: const Icon(Icons.task_alt_rounded, size: 18),
                      label: const Text('Selesai'),
                    ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      children: [
        Icon(icon, size: 14, color: PadelGoColors.textHint),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: PadelGoColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
