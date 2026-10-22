import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../models/admin_order.dart';
import '../services/supabase_service.dart';

/// State management sisi admin — pesanan masuk, slot yang ditutup
/// manual, dan pengaturan harga lapangan.
///
/// 100% live backend: semua data dari tabel `bookings`,
/// `closed_slots`, dan `courts` di Supabase.
class AdminProvider extends ChangeNotifier {
  /// ID lapangan yang dikelola (diisi dari DB saat loadAdminData).
  String _courtId = '';

  /// Tarif per jam yang bisa diubah admin.
  double _pricePerHour = 0;
  double get pricePerHour => _pricePerHour;

  /// Semua pesanan masuk, terurut terbaru dulu.
  final List<AdminOrder> _orders = [];
  List<AdminOrder> get orders {
    final list = List.of(_orders);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Slot yang ditutup manual per tanggal (key = 'yyyy-MM-dd').
  final Map<String, Set<int>> _closedSlots = {};

  static String _key(DateTime d) {
    d = DateUtils.dateOnly(d);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// Muat data admin dari Supabase: lapangan utama, semua pesanan,
  /// dan slot yang ditutup.
  Future<void> loadAdminData() async {
    if (!SupabaseService.isReady) return;
    try {
      final court = await SupabaseService.fetchPrimaryCourt();
      if (court != null) {
        _courtId = court.id;
        _pricePerHour = court.pricePerHour;
      }
      _orders
        ..clear()
        ..addAll(await SupabaseService.fetchOrders());
      _closedSlots
        ..clear()
        ..addAll(await SupabaseService.fetchClosedSlots(_courtId));
    } catch (_) {}
    notifyListeners();
  }

  /// Jam yang ditutup admin untuk tanggal tertentu.
  Set<int> closedSlotsFor(DateTime date) =>
      Set.unmodifiable(_closedSlots[_key(date)] ?? {});

  /// Jam yang dibooking customer untuk tanggal tertentu (dari pesanan masuk).
  Map<int, String> bookedByFor(DateTime date) {
    final map = <int, String>{};
    for (final o in _orders) {
      if (DateUtils.isSameDay(o.date, date)) {
        for (final h in o.slotHours) {
          map[h] = o.customerName;
        }
      }
    }
    return map;
  }

  // ---- Statistik dashboard ----

  /// Total pendapatan dari pesanan berstatus lunas/selesai.
  double get totalRevenue => _orders
      .where((o) =>
          o.paymentStatus == OrderPaymentStatus.paid ||
          o.paymentStatus == OrderPaymentStatus.completed)
      .fold(0.0, (sum, o) => sum + o.totalPrice);

  /// Pesanan yang dijadwalkan main hari ini, urut jam mulai.
  List<AdminOrder> get todayOrders {
    final now = DateTime.now();
    final list =
        _orders.where((o) => DateUtils.isSameDay(o.date, now)).toList();
    int start(AdminOrder o) => o.slotHours.reduce((a, b) => a < b ? a : b);
    list.sort((a, b) => start(a).compareTo(start(b)));
    return list;
  }

  /// Jumlah booking untuk hari ini.
  int get todayBookings =>
      _orders.where((o) => DateUtils.isSameDay(o.date, DateTime.now())).length;

  /// Pesanan yang menunggu validasi pembayaran.
  int get pendingOrders =>
      _orders.where((o) => o.paymentStatus == OrderPaymentStatus.pending).length;

  /// Jumlah lapangan aktif.
  int get activeCourts => _courtId.isEmpty ? 0 : 1;

  // ---- Aksi ----

  /// Konfirmasi pembayaran pesanan (menunggu -> lunas).
  void confirmPayment(String orderId) =>
      _setOrderStatus(orderId, OrderPaymentStatus.paid, 'confirmed');

  /// Tandai pesanan selesai (hanya admin — RLS menolak user biasa).
  void completeOrder(String orderId) =>
      _setOrderStatus(orderId, OrderPaymentStatus.completed, 'completed');

  /// Batalkan pesanan (hanya admin — RLS menolak user biasa).
  void cancelOrder(String orderId) =>
      _setOrderStatus(orderId, OrderPaymentStatus.cancelled, 'cancelled');

  void _setOrderStatus(
      String orderId, OrderPaymentStatus local, String dbStatus) {
    final i = _orders.indexWhere((o) => o.id == orderId);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(paymentStatus: local);
    notifyListeners();
    if (SupabaseService.isReady) {
      SupabaseService.setBookingStatus(orderId, dbStatus).ignore();
    }
  }

  /// Tutup/buka slot jam operasional secara manual.
  void toggleSlotClosed(DateTime date, int hour) {
    final key = _key(date);
    final slots = _closedSlots.putIfAbsent(key, () => {});
    final nowClosed = !slots.remove(hour);
    if (nowClosed) slots.add(hour);
    notifyListeners();
    if (SupabaseService.isReady) {
      SupabaseService.setSlotClosed(_courtId, date, hour, nowClosed)
          .ignore();
    }
  }

  /// Ubah tarif per jam lapangan.
  void setPricePerHour(double value) {
    _pricePerHour = value;
    notifyListeners();
    if (SupabaseService.isReady) {
      SupabaseService.updateCourtPrice(_courtId, value).ignore();
    }
  }
}
