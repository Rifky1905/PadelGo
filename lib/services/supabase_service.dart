import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/supabase_config.dart';
import '../models/admin_order.dart';
import '../models/booking.dart';
import '../models/court.dart';
import '../models/facility.dart';
import '../models/user.dart';
import '../utils/constants.dart';

/// Akses database Supabase PadelGo — satu-satunya sumber data app.
///
/// Semua method hanya berfungsi saat [SupabaseConfig.isConfigured]
/// bernilai true (URL + anon key sudah diisi).
class SupabaseService {
  SupabaseService._();

  /// true jika credentials sudah diisi di SupabaseConfig.
  static bool get isReady => SupabaseConfig.isConfigured;

  static sb.SupabaseClient get _c => sb.Supabase.instance.client;

  /// Inisialisasi SDK — dipanggil sekali di main() sebelum runApp.
  static Future<void> init() async {
    if (!isReady) return;
    // Normalisasi URL — buang spasi & trailing slash agar tidak
    // gagal karena salah copy-paste dari dashboard.
    var url = SupabaseConfig.url.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    await sb.Supabase.initialize(
      url: url,
      publishableKey: SupabaseConfig.anonKey.trim(),
    );
  }

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Terjemahkan error auth Supabase ke bahasa Indonesia.
  static AuthException _authErr(Object e) {
    final msg = e is sb.AuthException ? e.message : e.toString();
    if (msg.contains('Invalid login credentials')) {
      return AuthException('Email atau password salah');
    }
    if (msg.contains('User already registered')) {
      return AuthException('Email sudah terdaftar, silakan login');
    }
    if (msg.contains('rate limit')) {
      return AuthException(
          'Terlalu banyak percobaan. Tunggu sekitar 1 jam atau '
          'matikan "Confirm email" di dashboard Supabase.');
    }
    if (msg.contains('Email not confirmed')) {
      return AuthException(
          'Email belum dikonfirmasi. Cek inbox/spam email kamu.');
    }
    return AuthException(msg);
  }

  // ==================== AUTH & PROFILE ====================

  /// Login email+password → ambil profil (nama, role, poin) dari DB.
  static Future<User> signIn(String email, String password) async {
    try {
      await _c.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw _authErr(e);
    }
    return _profile(_c.auth.currentUser!.id);
  }

  /// Registrasi user baru — profil dibuat otomatis oleh trigger DB.
  static Future<User> signUp(String name, String email, String password) async {
    sb.AuthResponse res;
    try {
      res = await _c.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
    } catch (e) {
      throw _authErr(e);
    }
    final user = res.user;
    if (user == null || res.session == null) {
      throw AuthException(
          'Registrasi berhasil — cek email untuk konfirmasi lalu login.');
    }
    return _profile(user.id);
  }

  /// Profil dari sesi yang masih aktif (untuk restore saat app dibuka).
  static Future<User?> currentProfile() async {
    final u = _c.auth.currentUser;
    if (u == null) return null;
    return _profile(u.id);
  }

  static Future<User> _profile(String uid) async {
    final row =
        await _c.from('profiles').select().eq('id', uid).single();
    return User(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'User',
      email: row['email'] as String? ?? '',
      role: row['role'] == 'admin' ? AppRole.admin : AppRole.user,
      phone: row['phone'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      points: (row['points'] as num?)?.toInt() ?? 0,
    );
  }

  /// Perbarui nama/email/telepon profil user.
  static Future<void> updateProfile(
    String uid, {
    String? name,
    String? email,
    String? phone,
  }) =>
      _c.from('profiles').update({
        'name': ?name,
        'email': ?email,
        'phone': ?phone,
      }).eq('id', uid);

  /// Upload foto profil ke bucket 'avatars' dan simpan URL-nya di
  /// profiles.avatar_url — mengembalikan public URL foto baru.
  static Future<String> uploadAvatar(
      String uid, Uint8List bytes, String ext) async {
    final path = '$uid.$ext';
    await _c.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: sb.FileOptions(
            contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
            upsert: true,
          ),
        );
    // Cache-buster agar CircleAvatar langsung memuat foto baru.
    final url =
        '${_c.storage.from('avatars').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
    await _c.from('profiles').update({'avatar_url': url}).eq('id', uid);
    return url;
  }

  static Future<void> signOut() => _c.auth.signOut();

  // ==================== COURTS ====================

  /// Semua lapangan aktif.
  static Future<List<Court>> fetchCourts() async {
    final rows = await _c
        .from('courts')
        .select()
        .eq('is_active', true)
        .order('name');
    return [for (final r in rows) _courtFromRow(r)];
  }

  /// Lapangan utama (pertama yang aktif) — dipakai sisi admin.
  static Future<Court?> fetchPrimaryCourt() async {
    final rows = await _c
        .from('courts')
        .select()
        .eq('is_active', true)
        .order('name')
        .limit(1);
    return rows.isEmpty ? null : _courtFromRow(rows.first);
  }

  static Court _courtFromRow(Map<String, dynamic> r) => Court(
        id: r['id'] as String,
        name: r['name'] as String,
        address: r['address'] as String,
        pricePerHour: (r['price_per_hour'] as num).toDouble(),
        rating: (r['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (r['review_count'] as num?)?.toInt() ?? 0,
        distanceKm: (r['distance_km'] as num?)?.toDouble() ?? 0,
        category: r['category'] as String? ?? 'Premium',
        description: r['description'] as String? ?? '',
        facilities: [
          for (final f in (r['facilities'] as List?) ?? const [])
            Facility.values.byName(f as String),
        ],
        // Placeholder gradasi dipakai untuk variasi slide galeri.
        galleryColors: AppConstants.defaultGalleryColors,
        assetImages: [
          if (r['image_asset'] != null) r['image_asset'] as String,
        ],
      );

  /// Ubah tarif per jam (dari admin).
  static Future<void> updateCourtPrice(String courtId, double price) =>
      _c.from('courts').update({'price_per_hour': price}).eq('id', courtId);

  // ==================== BOOKINGS (USER) ====================

  /// Jam terisi untuk lapangan+tanggal: gabungan booking aktif
  /// (pending/confirmed) dan slot yang ditutup admin.
  static Future<Set<int>> occupiedHours(
      String courtId, DateTime date) async {
    final d = _dateStr(date);
    final booked = await _c
        .from('bookings')
        .select('slots')
        .eq('court_id', courtId)
        .eq('booking_date', d)
        .inFilter('status', ['pending', 'confirmed']);
    final closed = await _c
        .from('closed_slots')
        .select('hour')
        .eq('court_id', courtId)
        .eq('slot_date', d);
    return {
      for (final r in booked) ...(r['slots'] as List).cast<int>(),
      for (final r in closed) (r['hour'] as num).toInt(),
    };
  }

  /// Buat booking baru — upload bukti bayar ke bucket
  /// 'payment-proofs' lalu insert baris bookings.
  /// Mengembalikan booking_code (untuk tiket/QR).
  static Future<String> createBooking({
    required String userId,
    required String courtId,
    required DateTime date,
    required List<int> slotHours,
    required double totalPrice,
    required String paymentMethod,
    required Uint8List proofBytes,
    required String proofExt,
  }) async {
    final code = 'PG-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final proofUrl = await _uploadProof(code, proofBytes, proofExt);
    await _c.from('bookings').insert({
      'booking_code': code,
      'user_id': userId,
      'court_id': courtId,
      'booking_date': _dateStr(date),
      'slots': slotHours,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_proof_url': proofUrl,
      'status': 'pending',
    });
    return code;
  }

  /// Upload foto bukti pembayaran → kembalikan public URL-nya.
  static Future<String> _uploadProof(
      String code, Uint8List bytes, String ext) async {
    final path = '$code.$ext';
    await _c.storage.from('payment-proofs').uploadBinary(
          path,
          bytes,
          fileOptions: sb.FileOptions(
            contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
            upsert: true,
          ),
        );
    return _c.storage.from('payment-proofs').getPublicUrl(path);
  }

  /// Riwayat booking milik user (termasuk data lapangan).
  static Future<List<Booking>> fetchMyBookings(String userId) async {
    final rows = await _c
        .from('bookings')
        .select('*, courts(*)')
        .eq('user_id', userId)
        .order('booking_date', ascending: false);
    return [for (final r in rows) _bookingFromRow(r)];
  }

  static Booking _bookingFromRow(Map<String, dynamic> r) {
    return Booking(
      id: r['booking_code'] as String,
      court: _courtFromRow(r['courts'] as Map<String, dynamic>),
      date: DateTime.parse(r['booking_date'] as String),
      slotHours: (r['slots'] as List).cast<int>(),
      totalPrice: (r['total_price'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.byName(r['payment_method'] as String),
      status: BookingStatus.values.byName(r['status'] as String),
      createdAt: DateTime.parse(r['created_at'] as String),
    );
  }

  /// Ubah status booking (by booking_code) — hanya admin yang
  /// diizinkan oleh policy `bookings_update` (RLS).
  static Future<void> setBookingStatus(String bookingCode, String status) =>
      _c.from('bookings')
          .update({'status': status}).eq('booking_code', bookingCode);

  // ==================== ADMIN ====================

  static const _orderColumns = '*, profiles(name, phone), courts(name)';

  /// Semua pesanan masuk + data customer & lapangan (join).
  static Future<List<AdminOrder>> fetchOrders() async {
    final rows = await _c
        .from('bookings')
        .select(_orderColumns)
        .order('created_at', ascending: false);
    return [for (final r in rows) _orderFromRow(r)];
  }

  /// Transaksi lunas/selesai yang masuk (created_at) dalam rentang
  /// [start, end) — difilter langsung di server untuk laporan pendapatan.
  static Future<List<AdminOrder>> fetchRevenueOrders(
      DateTime start, DateTime end) async {
    final rows = await _c
        .from('bookings')
        .select(_orderColumns)
        .inFilter('status', ['confirmed', 'completed'])
        .gte('created_at', start.toUtc().toIso8601String())
        .lt('created_at', end.toUtc().toIso8601String())
        .order('created_at', ascending: false);
    return [for (final r in rows) _orderFromRow(r)];
  }

  static AdminOrder _orderFromRow(Map<String, dynamic> r) {
    final p = r['profiles'] as Map<String, dynamic>?;
    final c = r['courts'] as Map<String, dynamic>?;
    return AdminOrder(
      id: r['booking_code'] as String,
      customerName: p?['name'] as String? ?? 'User',
      customerPhone: p?['phone'] as String? ?? '-',
      courtName: c?['name'] as String? ?? '-',
      date: DateTime.parse(r['booking_date'] as String),
      slotHours: (r['slots'] as List).cast<int>(),
      totalPrice: (r['total_price'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.byName(r['payment_method'] as String),
      paymentStatus: switch (r['status'] as String) {
        'completed' => OrderPaymentStatus.completed,
        'cancelled' => OrderPaymentStatus.cancelled,
        'pending' => OrderPaymentStatus.pending,
        _ => OrderPaymentStatus.paid,
      },
      createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      paymentProofUrl: r['payment_proof_url'] as String?,
    );
  }

  // ==================== QRIS PEMBAYARAN ====================

  static const _qrisKey = 'qris_url';

  /// URL gambar QRIS terbaru dari `app_settings` — realtime, langsung
  /// memancarkan nilai baru saat admin memperbarui QRIS.
  static Stream<String?> qrisUrlStream() => _c
      .from('app_settings')
      .stream(primaryKey: ['key'])
      .eq('key', _qrisKey)
      .map((rows) => rows.isEmpty ? null : rows.first['value'] as String?);

  /// Upload gambar QRIS baru (admin) ke bucket 'payment-assets' lalu
  /// simpan URL-nya. Nama file unik agar cache browser ikut ter-refresh.
  static Future<String> uploadQris(Uint8List bytes, String ext) async {
    final path = 'qris/qris_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bucket = _c.storage.from('payment-assets');
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: sb.FileOptions(
        contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
      ),
    );
    final url = bucket.getPublicUrl(path);
    await _c.from('app_settings').upsert({
      'key': _qrisKey,
      'value': url,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return url;
  }

  /// Semua slot yang ditutup admin untuk sebuah lapangan,
  /// dikelompokkan per tanggal (key = 'yyyy-MM-dd').
  static Future<Map<String, Set<int>>> fetchClosedSlots(
      String courtId) async {
    final rows = await _c
        .from('closed_slots')
        .select('slot_date, hour')
        .eq('court_id', courtId);
    final map = <String, Set<int>>{};
    for (final r in rows) {
      map.putIfAbsent(r['slot_date'] as String, () => {})
          .add((r['hour'] as num).toInt());
    }
    return map;
  }

  /// Tutup atau buka kembali slot jam operasional.
  static Future<void> setSlotClosed(
    String courtId,
    DateTime date,
    int hour,
    bool closed,
  ) {
    final d = _dateStr(date);
    if (closed) {
      return _c.from('closed_slots').upsert({
        'court_id': courtId,
        'slot_date': d,
        'hour': hour,
      });
    }
    return _c
        .from('closed_slots')
        .delete()
        .eq('court_id', courtId)
        .eq('slot_date', d)
        .eq('hour', hour);
  }
}

/// Error autentikasi dengan pesan yang siap ditampilkan ke user.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
