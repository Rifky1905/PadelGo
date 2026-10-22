import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Status pesanan yang masuk ke admin (mengikuti kolom `status`
/// di tabel bookings: pending/confirmed/completed/cancelled).
enum OrderPaymentStatus {
  pending('Menunggu'),
  paid('Lunas'),
  completed('Selesai'),
  cancelled('Dibatalkan');

  const OrderPaymentStatus(this.label);
  final String label;
}

/// Data model pesanan masuk dari sisi admin/pengelola lapangan.
class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.slotHours,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.courtName = '-',
    this.paymentProofUrl,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final List<int> slotHours;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final OrderPaymentStatus paymentStatus;
  final DateTime createdAt;

  /// Nama lapangan yang dipesan, misal "PadelGo Court A".
  final String courtName;

  /// URL foto bukti pembayaran di Supabase Storage (null jika belum ada).
  final String? paymentProofUrl;

  /// Rentang waktu ringkas, misal "18:00 - 20:00".
  String get timeRange {
    final sorted = [...slotHours]..sort();
    return '${Formatters.jam(sorted.first)} - ${Formatters.jam(sorted.last + 1)}';
  }

  AdminOrder copyWith({OrderPaymentStatus? paymentStatus}) => AdminOrder(
        id: id,
        customerName: customerName,
        customerPhone: customerPhone,
        date: date,
        slotHours: slotHours,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        createdAt: createdAt,
        courtName: courtName,
        paymentProofUrl: paymentProofUrl,
      );
}
