import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/supabase_service.dart';

/// State management autentikasi (login / registrasi / logout) + role.
///
/// 100% live backend: auth memakai Supabase Auth dan role dibaca
/// dari kolom `role` pada tabel `profiles`.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _restoring = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == AppRole.admin;
  bool get isLoading => _isLoading;

  /// true saat sesi login Supabase sedang dipulihkan (app baru dibuka).
  bool get restoring => _restoring;
  String? get error => _error;

  static const _notConfigured =
      'Koneksi database belum dikonfigurasi (lihat supabase/README.md).';

  /// Pulihkan sesi Supabase yang masih aktif — dipanggil sekali saat
  /// app start agar user tidak perlu login ulang setelah refresh.
  Future<void> tryRestoreSession() async {
    if (!SupabaseService.isReady) return;
    _restoring = true;
    notifyListeners();
    try {
      _user = await SupabaseService.currentProfile();
    } catch (_) {
      _user = null;
    }
    _restoring = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password,
          {AppRole role = AppRole.user}) =>
      _run(() => SupabaseService.signIn(email, password));

  Future<bool> register(String name, String email, String password) =>
      _run(() => SupabaseService.signUp(name, email, password));

  /// Kirim email reset password (fitur "Lupa Kata Sandi").
  /// Mengembalikan true jika permintaan berhasil dikirim.
  Future<bool> resetPassword(String email) =>
      _runVoid(() => SupabaseService.resetPassword(email));

  /// Simpan password baru saat sesi recovery aktif (user membuka
  /// link reset dari email). Mengembalikan true jika berhasil.
  Future<bool> updatePassword(String newPassword) =>
      _runVoid(() => SupabaseService.updatePassword(newPassword));

  Future<bool> _runVoid(Future<void> Function() action) async {
    if (!SupabaseService.isReady) {
      _error = _notConfigured;
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Gagal terhubung ke server. Coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _run(Future<User> Function() action) async {
    if (!SupabaseService.isReady) {
      _error = _notConfigured;
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Gagal terhubung ke server. Coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Perbarui data profil user yang sedang login (lokal + database).
  void updateProfile({String? name, String? email, String? phone}) {
    if (_user == null) return;
    _user = _user!.copyWith(name: name, email: email, phone: phone);
    notifyListeners();
    if (SupabaseService.isReady) {
      SupabaseService.updateProfile(_user!.id,
              name: name, email: email, phone: phone)
          .ignore();
    }
  }

  /// Upload foto profil baru ke Storage dan perbarui avatar_url.
  /// Mengembalikan true jika berhasil.
  Future<bool> updateAvatar(Uint8List bytes, String ext) async {
    final u = _user;
    if (u == null || !SupabaseService.isReady) return false;
    try {
      final url = await SupabaseService.uploadAvatar(u.id, bytes, ext);
      _user = u.copyWith(avatarUrl: url);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
    if (SupabaseService.isReady) SupabaseService.signOut().ignore();
  }
}
