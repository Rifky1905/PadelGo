# Setup Supabase untuk PadelGo

Selama `lib/config/supabase_config.dart` belum diisi, aplikasi berjalan
dengan **mock data** (mode demo). Setelah diisi, seluruh data
(auth, lapangan, slot, booking, pesanan admin) otomatis memakai database.

## Langkah Setup

1. **Buat project** di https://supabase.com → *New project* (gratis).

2. **Jalankan skema**
   - Dashboard → **SQL Editor** → *New query*
   - Copy-paste seluruh isi `schema.sql` → **Run**
   - Ini membuat tabel `profiles`, `courts`, `bookings`, `closed_slots`,
     trigger profil otomatis, RLS policy, dan seed PadelGo Court A.

3. **Matikan konfirmasi email** (untuk development)
   - Dashboard → **Authentication** → **Providers** → Email
   - Matikan *"Confirm email"* → Save
   - (Bisa dinyalakan lagi nanti untuk production)

4. **Tempel credentials**
   - Dashboard → **Settings** → **API**
   - Copy *Project URL* dan *anon public key* ke
     `lib/config/supabase_config.dart`

5. **Buat akun admin**
   - Daftar akun via halaman registrasi di app (atau dashboard
     **Authentication → Users → Add user**)
   - Jalankan di SQL Editor:
     ```sql
     update public.profiles
     set role = 'admin'
     where email = 'email-admin-kamu@contoh.com';
     ```
   - Login dengan email tsb — `AuthProvider` membaca role dari database.

## Catatan

- `booking_code` (misal `PG-123456`) dipakai sebagai ID tiket & QR check-in.
- Status booking: `pending` → `confirmed` (admin konfirmasi) →
  `completed`/`cancelled`. `pending`+`confirmed` menempati slot.
- `switchRole` di app tetap simulasi lokal (tidak menulis ke DB) —
  role asli selalu berasal dari tabel `profiles`.
