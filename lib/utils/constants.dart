import 'package:flutter/material.dart';

/// Konstanta global aplikasi PadelGo.
class AppConstants {
  AppConstants._();

  static const String appName = 'PadelGo';

  /// Jam operasional lapangan: 06:00 - 22:00 (slot per jam).
  static const int openHour = 6;
  static const int closeHour = 22;

  /// Path asset foto lapangan utama.
  static const String courtImageAsset = 'assets/images/court_main.jpg';

  /// Alamat resmi lapangan PadelGo.
  static const String courtAddress =
      'Jl. Kartini Raya No.12, Depok, Kec. Pancoran Mas, '
      'Kota Depok, Jawa Barat';

  /// Koordinat perkiraan lokasi lapangan (Depok, Pancoran Mas).
  static const double courtLat = -6.3939;
  static const double courtLng = 106.8209;

  /// Kontak admin PadelGo.
  static const String adminWhatsapp = '6281586976601'; // format wa.me
  static const String adminPhoneDisplay = '0815-8697-6601';
  static const String adminEmail = 'admin@padelgo.id';

  /// Link Google Maps ke lokasi lapangan.
  static String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent('PadelGo Court, $courtAddress')}';

  /// Link chat WhatsApp admin dengan template pesan opsional.
  static String waMeUrl({String message = ''}) =>
      'https://wa.me/$adminWhatsapp'
      '${message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}'}';

  /// Template chat WhatsApp untuk user yang butuh bantuan.
  static const String waTemplate =
      'Halo Admin PadelGo! Saya butuh bantuan terkait booking lapangan. '
      'Mohon dibantu ya, terima kasih.';

  /// Warna gradasi default untuk placeholder galeri lapangan.
  static const List<List<Color>> defaultGalleryColors = [
    [Color(0xFFE91E63), Color(0xFF880E4F)],
    [Color(0xFFEC407A), Color(0xFFAD1457)],
    [Color(0xFFF06292), Color(0xFFC2185B)],
  ];

  static const List<String> categories = [
    'Semua',
    'Indoor',
    'Outdoor',
    'Premium',
    'Terdekat',
  ];

  /// Banner promo / kegiatan padel untuk beranda (konten statis).
  static const List<PromoBanner> promos = [
    PromoBanner(
      title: 'Diskon 30% Jam Pagi!',
      subtitle: 'Booking sebelum 10:00 di semua lapangan indoor',
      colors: [Color(0xFFE91E63), Color(0xFFFF6C9C)],
    ),
    PromoBanner(
      title: 'PadelGo Weekend Cup',
      subtitle: 'Turnamen komunitas • 25-26 Okt • Daftar sekarang',
      colors: [Color(0xFFC2185B), Color(0xFFE91E63)],
    ),
    PromoBanner(
      title: 'Gratis Sewa Raket',
      subtitle: 'Untuk booking minimal 2 jam di PadelGo Court A',
      colors: [Color(0xFFAD1457), Color(0xFFEC407A)],
    ),
  ];
}

/// Metode pembayaran mockup.
enum PaymentMethod {
  qris('QRIS', 'Scan kode QR — semua e-wallet & m-banking'),
  gopay('GoPay', 'Saldo e-wallet GoPay'),
  ovo('OVO', 'Saldo e-wallet OVO'),
  bca('Transfer Bank BCA', 'Cek otomatis, virtual account'),
  mandiri('Transfer Bank Mandiri', 'Cek otomatis, virtual account');

  const PaymentMethod(this.label, this.subtitle);
  final String label;
  final String subtitle;
}

/// Banner promo yang tampil di beranda.
class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
}
