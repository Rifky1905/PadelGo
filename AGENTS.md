# PadelGo — padel_go_app

Aplikasi Flutter untuk booking lapangan padel. Brand identity: pink (#E91E63).

## Environment

- Flutter SDK tidak ada di PATH — gunakan path absolut: `C:\Src\flutter\bin\flutter` (Flutter 3.47.6, Dart 3.13.5)
- Tidak ada Android SDK & Visual Studio → platform yang bisa dijalankan: **web (Chrome)** dan Windows tidak bisa.
- Jalankan dev server web: `C:\Src\flutter\bin\flutter run -d web-server --web-port=8080`

## Verifikasi

- `C:\Src\flutter\bin\flutter analyze` — harus "No issues found"
- `C:\Src\flutter\bin\flutter test` — smoke test login screen
- `C:\Src\flutter\bin\flutter build web --release` — verifikasi kompilasi penuh

## Struktur

- `lib/utils/` — `app_theme.dart` (PadelGoColors + ThemeData + GoogleFonts Plus Jakarta Sans), `formatters.dart` (Rupiah, tanggal ID), `constants.dart` (jam operasional 06-22, PaymentMethod)
- `lib/models/` — User (dengan `role: AppRole`), Court (dengan `assetImages`), Facility (enum + icon), Booking, AdminOrder (pesanan sisi admin, OrderPaymentStatus)
- `lib/config/` — `supabase_config.dart` (Project URL + anon key)
- `lib/services/` — `supabase_service.dart` (SATU-SATUNYA sumber data: auth/profile, courts, bookings, occupied slots, admin orders, closed_slots, harga) — tidak ada mock data
- `supabase/` — `schema.sql` (tabel profiles/courts/bookings/closed_slots + RLS + trigger + seed), `README.md` (langkah setup)
- `lib/providers/` — AuthProvider (dengan AppRole + switchRole), CourtProvider (search/filter), BookingProvider (riwayat user), AdminProvider (orders, slot tutup/buka, harga)
- `lib/views/landing/` — landing page responsif (entry point saat belum login); sub-widget di `landing/widgets/` (navbar, hero, info bar, facility, gallery, location, CTA, footer)
- `lib/views/user/` — home/, detail/, booking/ (slot + pembayaran), history/, profile/, `main_navigation.dart` (bottom nav user)
- `lib/views/admin/` — `admin_navigation.dart` (NavigationRail desktop / bottom nav mobile), dashboard, schedule, orders, pricing, `admin_qris_screen.dart` (upload QRIS), `revenue_detail_screen.dart` (filter Hari/Minggu/Bulan + grafik, query server-side by `created_at`), `today_bookings_screen.dart` (booking hari ini + aksi cepat)
- `lib/widgets/qris_image.dart` — gambar QRIS realtime (stream `app_settings` key `qris_url`), dipakai di admin & PaymentScreen
- `lib/views/auth/` — login (dengan pemilih role User/Admin), register
- `lib/widgets/` — PrimaryButton, CourtCard, CourtImage (asset/gradasi), TimeSlotTile, FacilityItem, BookingCard, SectionTitle
- `assets/images/court_main.jpg` — foto asli lapangan (dipakai di hero, galeri, detail, booking)

## Catatan

- Dependency: `provider`, `google_fonts: ^6.3.2` (JANGAN upgrade ke 9.x — API pakai material_ui, tidak kompatibel dgn Flutter material TextTheme), `qr_flutter` (QR tiket digital), `supabase_flutter`.
- **100% live backend**: semua provider memakai Supabase (guard `SupabaseService.isReady`). Role user dibaca dari `profiles.role`. Tidak ada mock data / akun demo / switch role lokal.
- Layar yang butuh Court memakai `CourtProvider.primaryCourt` (id uuid DB).
- Slot terisi di-cache di `CourtProvider._occupiedCache`, di-refresh via `loadOccupied` dan di-invalidate setelah booking dibuat.
- User flow: Landing → Login (wajib utk booking) → BookingScreen → PaymentScreen → TicketScreen (QR check-in). Bottom nav user: Beranda/Booking/Riwayat/Profil.
- Foto lapangan memakai asset asli `court_main.jpg`; `CourtImage` fallback ke gradasi jika asset null/error.
- Slot terisi = gabungan `bookings` (status pending/confirmed) + `closed_slots` untuk tanggal tsb (`SupabaseService.occupiedHours`).
- Bukti bayar: user wajib upload foto saat checkout → disimpan di bucket Storage `payment-proofs` (public read), URL di kolom `bookings.payment_proof_url`. Admin melihat bukti lewat tombol "Lihat Bukti Pembayaran".
- Status booking: `pending → confirmed → completed` atau `cancelled`. Update hanya admin — policy `bookings_update` RLS menolak user biasa.
- Migrasi DB incremental ada di `supabase/migration_*.sql` — jalankan berurutan jika schema.sql sudah pernah di-run sebelumnya.
- Port 8080 bisa tertinggal saat kill `flutter run`; gunakan port lain (8090).

## Git & Deployment

- Remote: `https://github.com/Rifky1905/PadelGo.git` (branch `main`). Commit pakai `git -c user.name="Rifky Arya Firdaus" -c user.email="Rifky1905@users.noreply.github.com"` (config identitas belum diset user).
- **Auto-commit**: setiap selesai mengubah kode, jalankan `git add -A` + commit + `git push origin main` (diminta user).
- CI/CD: `.github/workflows/deploy.yml` — push ke `main` → `flutter build web --release --base-href /PadelGo/` → deploy GitHub Pages (`https://rifky1905.github.io/PadelGo/`).
