import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/links.dart';

/// Pusat Bantuan & FAQ — pertanyaan umum + kontak support.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    (
      'Bagaimana cara booking lapangan?',
      'Pilih lapangan di beranda atau tab Booking, pilih tanggal & jam yang '
          'tersedia, lalu lanjutkan ke pembayaran. Tiket digital dengan QR '
          'code akan terbit setelah pembayaran berhasil.',
    ),
    (
      'Bagaimana cara check-in di lapangan?',
      'Tunjukkan tiket digital (QR code) di halaman Riwayat kepada petugas '
          'lapangan saat tiba. Petugas akan memindai kode untuk verifikasi.',
    ),
    (
      'Apakah bisa membatalkan booking?',
      'Pembatalan dapat dilakukan maksimal 6 jam sebelum jadwal main. '
          'Hubungi admin via WhatsApp untuk proses refund.',
    ),
    (
      'Metode pembayaran apa saja yang didukung?',
      'PadelGo mendukung QRIS, e-wallet (GoPay, OVO, DANA), dan transfer '
          'bank (BCA & Mandiri) dengan verifikasi otomatis.',
    ),
    (
      'Apakah tersedia sewa raket & bola?',
      'Ya, Pro Shop di lokasi menyediakan sewa raket (mulai Rp 30rb) dan '
          'bola padel. Bisa juga beli aksesori padel lainnya.',
    ),
    (
      'Bagaimana cara poin member bekerja?',
      'Setiap booking 1 jam = 10 poin. Kumpulkan 1.000 poin untuk naik ke '
          'Gold Member dan dapatkan diskon khusus member.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Kartu kontak cepat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: PadelGoColors.pinkGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Butuh bantuan langsung?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tim kami siap membantu setiap hari 06:00 - 22:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _contactChip(
                      Icons.chat_bubble_outline,
                      'WhatsApp',
                      onTap: () => openLink(AppConstants.waMeUrl(
                          message: AppConstants.waTemplate)),
                    ),
                    const SizedBox(width: 10),
                    _contactChip(
                      Icons.email_outlined,
                      'Email',
                      onTap: () => openLink(
                          'mailto:${AppConstants.adminEmail}'
                          '?subject=${Uri.encodeComponent('Bantuan PadelGo')}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PadelGoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // FAQ accordion
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _faqs.length; i++) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        _faqs[i].$1,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: PadelGoColors.textPrimary,
                        ),
                      ),
                      iconColor: PadelGoColors.primary,
                      childrenPadding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 14),
                      children: [
                        Text(
                          _faqs[i].$2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.55,
                            color: PadelGoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactChip(IconData icon, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
