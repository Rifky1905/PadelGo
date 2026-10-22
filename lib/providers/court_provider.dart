import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../models/court.dart';
import '../services/supabase_service.dart';

/// State management daftar lapangan + pencarian & filter kategori.
///
/// 100% live backend: lapangan dan ketersediaan slot selalu diambil
/// dari Supabase (tabel `courts`, `bookings`, `closed_slots`).
class CourtProvider extends ChangeNotifier {
  List<Court> _courts = const [];
  bool _loadingCourts = false;

  /// Cache slot terisi dari DB per "courtId|yyyy-MM-dd".
  final Map<String, Set<int>> _occupiedCache = {};

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _loadingCourts;

  /// Lapangan utama — dipakai semua layar yang menampilkan Court A.
  Court? get primaryCourt => _courts.isEmpty ? null : _courts.first;

  static String _key(DateTime d) {
    d = DateUtils.dateOnly(d);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// Ambil daftar lapangan dari Supabase.
  Future<void> loadCourts() async {
    if (!SupabaseService.isReady || _loadingCourts) return;
    _loadingCourts = true;
    try {
      _courts = await SupabaseService.fetchCourts();
    } catch (_) {
      // Pertahankan data saat ini bila fetch gagal.
    }
    _loadingCourts = false;
    notifyListeners();
  }

  /// Slot terisi (booking aktif + ditutup admin) dari cache DB.
  Set<int> occupiedFor(String courtId, DateTime date) =>
      _occupiedCache['$courtId|${_key(date)}'] ?? {};

  /// Muat/refresh slot terisi dari Supabase.
  Future<void> loadOccupied(String courtId, DateTime date) async {
    if (!SupabaseService.isReady) return;
    try {
      _occupiedCache['$courtId|${_key(date)}'] =
          await SupabaseService.occupiedHours(courtId, date);
      notifyListeners();
    } catch (_) {}
  }

  /// Hapus cache slot tanggal tertentu — dipanggil setelah booking
  /// baru dibuat agar slot langsung tampil terisi.
  void invalidateOccupied(String courtId, DateTime date) {
    _occupiedCache.remove('$courtId|${_key(date)}');
  }

  /// Sinkronkan harga lokal setelah admin mengubah tarif.
  void updateLocalPrice(double price) {
    _courts = [
      for (final c in _courts)
        c.id == primaryCourt?.id ? c.copyWith(pricePerHour: price) : c,
    ];
    notifyListeners();
  }

  /// Lapangan terfilter berdasar kategori + kata kunci pencarian.
  List<Court> get courts {
    Iterable<Court> result = _courts;

    if (_selectedCategory == 'Terdekat') {
      result = result.toList()..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_selectedCategory != 'Semua') {
      result =
          result.where((c) => c.category == _selectedCategory);
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q));
    }
    return result.toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
