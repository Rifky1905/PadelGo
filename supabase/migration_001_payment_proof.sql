-- ============================================================
-- Migrasi 001 — Bukti pembayaran + status hanya oleh admin
-- Jalankan di SQL Editor jika schema.sql sudah pernah di-run
-- sebelumnya (tidak perlu untuk setup baru — sudah termasuk).
-- ============================================================

-- 1. Kolom URL bukti pembayaran
alter table public.bookings
  add column if not exists payment_proof_url text;

-- 2. UPDATE bookings hanya untuk admin (confirmed/completed/cancelled)
drop policy if exists "bookings_update" on public.bookings;
create policy "bookings_update" on public.bookings
  for update using (public.is_admin()) with check (public.is_admin());

-- 3. Bucket storage untuk foto bukti pembayaran (public read)
insert into storage.buckets (id, name, public)
values ('payment-proofs', 'payment-proofs', true)
on conflict (id) do nothing;

drop policy if exists "proofs_insert_auth" on storage.objects;
create policy "proofs_insert_auth" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'payment-proofs');

drop policy if exists "proofs_select_all" on storage.objects;
create policy "proofs_select_all" on storage.objects
  for select using (bucket_id = 'payment-proofs');
