import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/court.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

/// State management pesanan — riwayat booking pengguna.
///
/// 100% live backend: booking ditulis ke tabel `bookings` dan
/// riwayat diambil dari sana untuk akun yang sedang login.
class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  /// Pesanan mendatang/aktif (menunggu konfirmasi & terkonfirmasi),
  /// terurut dari tanggal terdekat.
  List<Booking> get upcoming {
    final list = _bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Pesanan selesai/dibatalkan admin, terurut terbaru dulu.
  List<Booking> get completed {
    final list = _bookings
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Muat riwayat booking user dari Supabase.
  Future<void> loadBookings(String? userId) async {
    if (!SupabaseService.isReady || userId == null) return;
    try {
      final rows = await SupabaseService.fetchMyBookings(userId);
      _bookings
        ..clear()
        ..addAll(rows);
      notifyListeners();
    } catch (_) {}
  }

  /// Buat pesanan baru — upload bukti bayar + menulis baris ke
  /// tabel `bookings`, lalu mengembalikan Booking dengan
  /// id = booking_code (tiket/QR). Status awal 'pending' —
  /// hanya admin yang bisa mengubah ke completed/cancelled.
  Future<Booking> createBooking({
    required Court court,
    required DateTime date,
    required List<int> slotHours,
    required PaymentMethod paymentMethod,
    required String userId,
    required Uint8List proofBytes,
    required String proofExt,
  }) async {
    final slots = List.of(slotHours)..sort();
    final total = court.pricePerHour * slots.length + 5000;
    final id = await SupabaseService.createBooking(
      userId: userId,
      courtId: court.id,
      date: date,
      slotHours: slots,
      totalPrice: total,
      paymentMethod: paymentMethod.name,
      proofBytes: proofBytes,
      proofExt: proofExt,
    );
    final booking = Booking(
      id: id,
      court: court,
      date: date,
      slotHours: slots,
      totalPrice: total,
      paymentMethod: paymentMethod,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
    _bookings.add(booking);
    notifyListeners();
    return booking;
  }
}
