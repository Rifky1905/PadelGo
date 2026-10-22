-- ============================================================
-- Migrasi 004 — Foto profil + alamat lapangan baru
-- Jalankan di SQL Editor (urut setelah migration_003).
-- ============================================================

-- 1. Kolom foto profil
alter table public.profiles
  add column if not exists avatar_url text;

-- 2. Bucket storage untuk foto profil (public read)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_insert_auth" on storage.objects;
create policy "avatars_insert_auth" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars');

drop policy if exists "avatars_update_auth" on storage.objects;
create policy "avatars_update_auth" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars') with check (bucket_id = 'avatars');

drop policy if exists "avatars_select_all" on storage.objects;
create policy "avatars_select_all" on storage.objects
  for select using (bucket_id = 'avatars');

-- 3. Alamat resmi lapangan
update public.courts
set address = 'Jl. Kartini Raya No.12, Depok, Kec. Pancoran Mas, '
              'Kota Depok, Jawa Barat'
where name = 'PadelGo Court A';
