/// Konfigurasi koneksi Supabase untuk PadelGo.
///
/// Isi [url] dan [anonKey] dari dashboard project Supabase
/// (Settings → API). Panduan lengkap: `supabase/README.md`.
///
/// Aplikasi berjalan 100% dengan backend Supabase — tidak ada
/// mock data; seluruh data berasal dari tabel `profiles`,
/// `courts`, `bookings`, dan `closed_slots`.
class SupabaseConfig {
  SupabaseConfig._();

  /// Project URL, misal 'https://abcdefghijk.supabase.co'.
  static const String url = 'https://gcvmdpkxclenugvdyojm.supabase.co';

  /// API key "anon public" dari Settings → API.
  static const String anonKey =
      'sb_publishable_4NguGNmSpDvIe0sqn6rLOw_D0G5VCU6';

  /// true jika koneksi database sudah dikonfigurasi
  /// (URL + anon key sama-sama terisi).
  static bool get isConfigured =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}
