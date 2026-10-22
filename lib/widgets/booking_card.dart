import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'court_image.dart';

/// Kartu ringkasan pesanan pada halaman riwayat.
/// Tap kartu untuk membuka tiket digital.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusBg) = switch (booking.status) {
      BookingStatus.pending => (
          'Menunggu',
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7)
        ),
      BookingStatus.confirmed => (
          'Aktif',
          PadelGoColors.available,
          PadelGoColors.availableBg
        ),
      BookingStatus.completed => (
          'Selesai',
          PadelGoColors.booked,
          PadelGoColors.bookedBg
        ),
      BookingStatus.cancelled => (
          'Dibatalkan',
          const Color(0xFFDC2626),
          const Color(0xFFFEE2E2)
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PadelGoColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CourtImage(
                colors: booking.court.galleryColors.first,
                width: 64,
                height: 64,
                borderRadius: 12,
                iconSize: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.court.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: PadelGoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.tanggalPendek(booking.date),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: PadelGoColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.timeRange} • ${booking.durationHours} jam',
                      style: const TextStyle(
                        fontSize: 12.5,
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
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID ${booking.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: PadelGoColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.rupiah(booking.totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: PadelGoColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
