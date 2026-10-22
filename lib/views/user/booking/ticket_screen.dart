import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/booking.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/formatters.dart';
import '../main_navigation.dart';

/// Tiket digital — QR code check-in yang ditunjukkan ke petugas lapangan.
class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiket Digital')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Badge sukses
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: PadelGoColors.availableBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: PadelGoColors.available, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Booking Berhasil!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tunjukkan QR ini ke petugas saat tiba di lokasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: PadelGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),

          // Kartu tiket
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header pink
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    gradient: PadelGoColors.pinkGradient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PADELGO E-TICKET',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.court.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        booking.court.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Detail
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _row('Tanggal',
                          Formatters.tanggalPanjang(booking.date)),
                      const SizedBox(height: 10),
                      _row('Jam',
                          '${booking.timeRange} (${booking.durationHours} jam)'),
                      const SizedBox(height: 10),
                      _row('Pembayaran', booking.paymentMethod.label),
                      const SizedBox(height: 10),
                      _row('Total',
                          Formatters.rupiah(booking.totalPrice),
                          valueColor: PadelGoColors.primary),
                    ],
                  ),
                ),

                // Pembatas tiket (garis putus-putus)
                const _DashedDivider(),

                // QR code check-in
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: PadelGoColors.divider),
                        ),
                        child: QrImageView(
                          data: 'PADELGO:${booking.id}',
                          version: QrVersions.auto,
                          size: 160,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: PadelGoColors.textPrimary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: PadelGoColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kode Booking',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PadelGoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => MainNavigation.goToHistory(context),
            icon: const Icon(Icons.receipt_long_outlined, size: 19),
            label: const Text('Lihat Riwayat Pesanan'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(color: PadelGoColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: PadelGoColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: valueColor ?? PadelGoColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Garis putus-putus pemisah tiket dengan lekukan di kedua sisi.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.maxWidth / 14).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  dashCount,
                  (_) => Container(
                    width: 8,
                    height: 2,
                    color: PadelGoColors.divider,
                  ),
                ),
              );
            },
          ),
          // Lekukan kiri-kanan
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: PadelGoColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: PadelGoColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
