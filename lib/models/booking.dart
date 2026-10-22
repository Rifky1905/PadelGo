import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'court.dart';

/// Status booking mengikuti kolom `status` di tabel bookings.
/// `completed` dan `cancelled` hanya bisa di-set oleh admin.
enum BookingStatus { pending, confirmed, completed, cancelled }

/// Data model untuk pesanan booking lapangan.
class Booking {
  const Booking({
    required this.id,
    required this.court,
    required this.date,
    required this.slotHours,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final Court court;
  final DateTime date;

  /// Jam mulai tiap slot yang dipesan, misal [7, 8] = 07:00-08:00 & 08:00-09:00.
  final List<int> slotHours;

  final double totalPrice;
  final PaymentMethod paymentMethod;
  final BookingStatus status;
  final DateTime createdAt;

  int get durationHours => slotHours.length;

  /// Rentang waktu ringkas, misal "07:00 - 09:00".
  String get timeRange {
    final sorted = [...slotHours]..sort();
    return '${Formatters.jam(sorted.first)} - ${Formatters.jam(sorted.last + 1)}';
  }

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        court: court,
        date: date,
        slotHours: slotHours,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
