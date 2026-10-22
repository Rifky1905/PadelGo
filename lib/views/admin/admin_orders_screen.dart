import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';

/// Daftar validasi pesanan — pesanan masuk + status pembayaran +
/// detail pemesan + aksi konfirmasi.
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final orders = admin.orders;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Validasi Pesanan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PadelGoColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${admin.pendingOrders} menunggu',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PadelGoColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'Belum ada pesanan masuk.',
                style: TextStyle(color: PadelGoColors.textSecondary),
              ),
            ),
          )
        else
          for (final order in orders) AdminOrderCard(order: order),
      ],
    );
  }
}

/// Kartu pesanan admin — dipakai di halaman Pesanan & Dashboard.
class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({super.key, required this.order, this.compact = false});

  final AdminOrder order;

  /// Mode ringkas tanpa aksi konfirmasi (untuk dashboard).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = switch (order.paymentStatus) {
      OrderPaymentStatus.pending =>
        (const Color(0xFFD97706), const Color(0xFFFEF3C7)),
      OrderPaymentStatus.paid =>
        (PadelGoColors.available, PadelGoColors.availableBg),
      OrderPaymentStatus.completed =>
        (const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
      OrderPaymentStatus.cancelled =>
        (const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PadelGoColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: PadelGoColors.primarySoft,
                child: Text(
                  order.customerName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: PadelGoColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerPhone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.tanggalPendek(order.date)} • ${order.timeRange}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.courtName} • ${order.id} • ${order.paymentMethod.label}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.rupiah(order.totalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: PadelGoColors.primary,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            // Bukti pembayaran — bisa dicek kapan pun selama ada.
            if (order.paymentProofUrl != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showProof(context, order.paymentProofUrl!),
                  icon: const Icon(Icons.receipt_outlined, size: 18),
                  label: const Text('Lihat Bukti Pembayaran'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (order.paymentStatus == OrderPaymentStatus.pending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .read<AdminProvider>()
                      .confirmPayment(order.id),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Konfirmasi Pembayaran'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ),
            if (order.paymentStatus == OrderPaymentStatus.paid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .read<AdminProvider>()
                      .completeOrder(order.id),
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text('Tandai Pesanan Selesai'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ),
            if (order.paymentStatus == OrderPaymentStatus.pending ||
                order.paymentStatus == OrderPaymentStatus.paid)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => confirmCancel(context, order),
                  icon: const Icon(Icons.cancel_outlined,
                      size: 17, color: Color(0xFFDC2626)),
                  label: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(color: Color(0xFFDC2626)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Dialog pratinjau foto bukti pembayaran dari Storage.
  static void showProof(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bukti Pembayaran',
                  style: TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420, maxWidth: 420),
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, child, p) => p == null
                      ? child
                      : const Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(),
                        ),
                  errorBuilder: (c, e, s) => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Text('Gagal memuat gambar bukti.'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog konfirmasi sebelum membatalkan pesanan.
  static void confirmCancel(BuildContext context, AdminOrder order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text(
          'Pesanan ${order.id} milik ${order.customerName} akan '
          'dibatalkan. Tindakan ini tidak bisa diurungkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AdminProvider>().cancelOrder(order.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
