-- ============================================================
-- Migrasi 003 — Pengaturan QRIS pembayaran oleh admin
-- ============================================================

-- 1. Tabel pengaturan aplikasi (key-value), misal key 'qris_url'
create table if not exists public.app_settings (
  key        text primary key,
  value      text,
  updated_at timestamptz not null default now()
);

alter table public.app_settings enable row level security;

drop policy if exists "app_settings_select_all" on public.app_settings;
create policy "app_settings_select_all" on public.app_settings
  for select using (true);

drop policy if exists "app_settings_admin_write" on public.app_settings;
create policy "app_settings_admin_write" on public.app_settings
  for all using (public.is_admin()) with check (public.is_admin());

-- 2. Realtime — checkout user langsung menerima QRIS terbaru
do $$
begin
  alter publication supabase_realtime add table public.app_settings;
exception when duplicate_object then null;
end $$;

-- 3. Bucket 'payment-assets' (public read, hanya admin yang upload)
insert into storage.buckets (id, name, public)
values ('payment-assets', 'payment-assets', true)
on conflict (id) do nothing;

drop policy if exists "payment_assets_select_all" on storage.objects;
create policy "payment_assets_select_all" on storage.objects
  for select using (bucket_id = 'payment-assets');

drop policy if exists "payment_assets_admin_insert" on storage.objects;
create policy "payment_assets_admin_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'payment-assets' and public.is_admin());

drop policy if exists "payment_assets_admin_update" on storage.objects;
create policy "payment_assets_admin_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'payment-assets' and public.is_admin());

drop policy if exists "payment_assets_admin_delete" on storage.objects;
create policy "payment_assets_admin_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'payment-assets' and public.is_admin());

-- 4. Index untuk filter pendapatan per rentang waktu
create index if not exists bookings_created_at_idx
  on public.bookings (created_at);
create index if not exists bookings_booking_date_idx
  on public.bookings (booking_date);
