import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';

/// Halaman dokumen legal — dipakai untuk Syarat & Ketentuan dan
/// Kebijakan Privasi dengan isi berbeda.
class LegalScreen extends StatelessWidget {
  const LegalScreen._(this.title, this.sections);

  /// Syarat & Ketentuan penggunaan aplikasi PadelGo.
  factory LegalScreen.terms() => const LegalScreen._(
        'Syarat & Ketentuan',
        _termsSections,
      );

  /// Kebijakan Privasi PadelGo.
  factory LegalScreen.privacy() => const LegalScreen._(
        'Kebijakan Privasi',
        _privacySections,
      );

  final String title;
  final List<(String, String)> sections;

  static const _termsSections = [
    (
      '1. Pemesanan Lapangan',
      'Booking dilakukan melalui aplikasi PadelGo dengan memilih tanggal '
          'dan jam yang tersedia. Pesanan dianggap sah setelah pengguna '
          'mengunggah bukti pembayaran dan diverifikasi oleh admin '
          'lapangan. Slot yang sudah dibooking tidak dapat dipindahtangankan '
          'kepada pihak lain tanpa persetujuan pengelola.',
    ),
    (
      '2. Pembayaran',
      'Pembayaran dilakukan melalui metode yang tersedia (QRIS, e-wallet, '
          'atau transfer bank). Pengguna wajib mengunggah bukti pembayaran '
          'yang valid dan dapat dibaca. Pesanan akan berstatus "Menunggu" '
          'hingga admin mengonfirmasi pembayaran.',
    ),
    (
      '3. Pembatalan & Pengembalian Dana',
      'Pembatalan hanya dapat dilakukan oleh admin lapangan. Pengajuan '
          'pembatalan dilakukan melalui WhatsApp admin maksimal 6 jam '
          'sebelum jadwal bermain. Pengembalian dana diproses dalam '
          '1x24 jam setelah pembatalan disetujui.',
    ),
    (
      '4. Check-in',
      'Pengguna wajib menunjukkan tiket digital (QR code) kepada petugas '
          'saat tiba di lokasi. Keterlambatan lebih dari 30 menit tanpa '
          'konfirmasi dapat mengakibatkan slot dialihkan ke pengguna lain.',
    ),
    (
      '5. Tata Tertib Lapangan',
      'Pengguna wajib menggunakan sepatu non-marking, menjaga kebersihan '
          'fasilitas, dan mengikuti arahan petugas. Kerusakan fasilitas '
          'yang disebabkan kelalaian menjadi tanggung jawab pengguna.',
    ),
    (
      '6. Perubahan Ketentuan',
      'PadelGo berhak mengubah syarat & ketentuan ini sewaktu-waktu. '
          'Perubahan akan diumumkan melalui aplikasi dan berlaku sejak '
          'tanggal diterbitkan.',
    ),
  ];

  static const _privacySections = [
    (
      '1. Data yang Kami Kumpulkan',
      'Kami mengumpulkan data yang Anda berikan saat registrasi dan '
          'penggunaan aplikasi: nama, alamat email, nomor telepon, foto '
          'profil, serta riwayat pemesanan lapangan.',
    ),
    (
      '2. Penggunaan Data',
      'Data digunakan untuk memproses booking, verifikasi pembayaran, '
          'komunikasi terkait pesanan, dan peningkatan layanan. Foto bukti '
          'pembayaran hanya diakses oleh admin untuk keperluan validasi.',
    ),
    (
      '3. Penyimpanan & Keamanan',
      'Data disimpan dengan aman di server Supabase dengan kontrol akses '
          'berbasis peran (Row Level Security). Kami tidak menjual atau '
          'membagikan data pribadi Anda kepada pihak ketiga tanpa '
          'persetujuan.',
    ),
    (
      '4. Foto Profil & Bukti Pembayaran',
      'Foto profil dan bukti pembayaran yang diunggah tersimpan di '
          'penyimpanan cloud PadelGo. Anda dapat mengganti foto profil '
          'kapan saja melalui menu Pengaturan Akun.',
    ),
    (
      '5. Hak Pengguna',
      'Anda berhak meminta perbaikan atau penghapusan data akun dengan '
          'menghubungi admin melalui WhatsApp yang tersedia di aplikasi. '
          'Penghapusan akun akan menghapus profil beserta riwayat '
          'pemesanan terkait.',
    ),
    (
      '6. Kontak',
      'Pertanyaan terkait privasi dapat disampaikan melalui email '
          'admin@padelgo.id atau WhatsApp admin PadelGo pada jam '
          'operasional 06:00 - 22:00 WIB.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelGoColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terakhir diperbarui: Oktober 2026',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: PadelGoColors.textHint,
                  ),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  Text(
                    sections[i].$1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: PadelGoColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sections[i].$2,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: PadelGoColors.textSecondary,
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
}
