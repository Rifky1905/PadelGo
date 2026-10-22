-- ============================================================
-- PadelGo — Skema Database Supabase
-- Jalankan SELURUH file ini di Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- ------------------------------------------------------------
-- 1. PROFILES — data user (memperluas auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  email      text,
  phone      text,
  avatar_url text,                              -- URL foto profil di bucket 'avatars'
  role       text not null default 'user' check (role in ('user', 'admin')),
  points     int  not null default 0,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2. COURTS — lapangan padel
-- ------------------------------------------------------------
create table if not exists public.courts (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  description    text,
  address        text not null,
  price_per_hour numeric not null,
  rating         numeric(2,1) not null default 4.9,
  review_count   int not null default 0,
  distance_km    numeric(4,1),
  category       text not null default 'Premium',
  image_asset    text,              -- path asset lokal, misal 'assets/images/court_main.jpg'
  facilities     text[] not null default '{}', -- nama enum Facility: locker, ac, parking, racketRental, cafe, shower, wifi, mushola
  is_active      boolean not null default true,
  created_at     timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. BOOKINGS — pesanan user (sekaligus data validasi admin)
-- ------------------------------------------------------------
create table if not exists public.bookings (
  id             uuid primary key default gen_random_uuid(),
  booking_code   text not null unique,          -- misal 'PG-123456', dipakai di tiket QR
  user_id        uuid not null references public.profiles(id) on delete cascade,
  court_id       uuid not null references public.courts(id) on delete cascade,
  booking_date   date not null,
  slots          int[] not null,                -- jam mulai, misal {18,19}
  total_price    numeric not null,
  payment_method text not null,                 -- qris | gopay | ovo | bca | mandiri
  payment_proof_url text,                       -- URL foto bukti bayar di bucket 'payment-proofs'
  status         text not null default 'pending'
                 check (status in ('pending','confirmed','completed','cancelled')),
  created_at     timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. CLOSED_SLOTS — jam yang ditutup manual oleh admin
-- ------------------------------------------------------------
create table if not exists public.closed_slots (
  court_id  uuid not null references public.courts(id) on delete cascade,
  slot_date date not null,
  hour      int  not null check (hour between 0 and 23),
  primary key (court_id, slot_date, hour)
);

-- ------------------------------------------------------------
-- 5. HELPER — cek apakah user yang login adalah admin
--    (security definer agar tidak rekursif di policy profiles)
-- ------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql security definer stable
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ------------------------------------------------------------
-- 6. TRIGGER — buat profil otomatis saat user baru mendaftar
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    new.raw_user_meta_data->>'phone',
    'user'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- 7. ROW LEVEL SECURITY
-- ------------------------------------------------------------
alter table public.profiles     enable row level security;
alter table public.courts       enable row level security;
alter table public.bookings     enable row level security;
alter table public.closed_slots enable row level security;

-- profiles: user baca & update miliknya sendiri; admin baca semua
create policy "profiles_select_own"  on public.profiles
  for select using (auth.uid() = id or public.is_admin());
create policy "profiles_update_own"  on public.profiles
  for update using (auth.uid() = id);

create or replace function public.protect_profile_role()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role
     and auth.uid() is not null
     and not public.is_admin() then
    raise exception 'Hanya admin yang boleh mengubah role';
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_role on public.profiles;
create trigger protect_profile_role
  before update on public.profiles
  for each row execute function public.protect_profile_role();

-- courts: bisa dibaca semua orang (landing page publik),
-- hanya admin yang bisa mengubah
create policy "courts_select_all"  on public.courts
  for select using (true);
create policy "courts_admin_write" on public.courts
  for all using (public.is_admin()) with check (public.is_admin());

-- bookings: user baca & buat miliknya sendiri; admin baca semua.
-- UPDATE hanya admin — status confirmed/completed/cancelled tidak
-- bisa diubah user dari sisi klien.
create policy "bookings_select" on public.bookings
  for select using (auth.uid() = user_id or public.is_admin());
create policy "bookings_insert" on public.bookings
  for insert with check (auth.uid() = user_id);
create policy "bookings_update" on public.bookings
  for update using (public.is_admin()) with check (public.is_admin());

-- closed_slots: bisa dibaca semua (status slot untuk user),
-- hanya admin yang bisa menutup/membuka
create policy "closed_slots_select" on public.closed_slots
  for select using (true);
create policy "closed_slots_admin"  on public.closed_slots
  for all using (public.is_admin()) with check (public.is_admin());

-- ------------------------------------------------------------
-- 8. STORAGE — bucket 'payment-proofs' untuk foto bukti bayar
--    (public agar admin bisa melihat bukti via URL)
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('payment-proofs', 'payment-proofs', true)
on conflict (id) do nothing;

create policy "proofs_insert_auth" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'payment-proofs');
create policy "proofs_select_all" on storage.objects
  for select using (bucket_id = 'payment-proofs');

-- ------------------------------------------------------------
-- 8b. APP SETTINGS + bucket 'payment-assets' (QRIS dari admin)
-- ------------------------------------------------------------
create table if not exists public.app_settings (
  key        text primary key,
  value      text,
  updated_at timestamptz not null default now()
);
alter table public.app_settings enable row level security;
create policy "app_settings_select_all" on public.app_settings
  for select using (true);
create policy "app_settings_admin_write" on public.app_settings
  for all using (public.is_admin()) with check (public.is_admin());

do $$
begin
  alter publication supabase_realtime add table public.app_settings;
exception when duplicate_object then null;
end $$;

insert into storage.buckets (id, name, public)
values ('payment-assets', 'payment-assets', true)
on conflict (id) do nothing;

create policy "payment_assets_select_all" on storage.objects
  for select using (bucket_id = 'payment-assets');
create policy "payment_assets_admin_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'payment-assets' and public.is_admin());
create policy "payment_assets_admin_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'payment-assets' and public.is_admin());
create policy "payment_assets_admin_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'payment-assets' and public.is_admin());

-- Bucket 'avatars' untuk foto profil user (public read)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "avatars_insert_auth" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars');
create policy "avatars_update_auth" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars') with check (bucket_id = 'avatars');
create policy "avatars_select_all" on storage.objects
  for select using (bucket_id = 'avatars');

create index if not exists bookings_created_at_idx
  on public.bookings (created_at);
create index if not exists bookings_booking_date_idx
  on public.bookings (booking_date);

-- ------------------------------------------------------------
-- 9. SEED — lapangan utama PadelGo
-- ------------------------------------------------------------
insert into public.courts (
  name, description, address, price_per_hour, rating, review_count,
  distance_km, category, image_asset, facilities
) values (
  'PadelGo Court A',
  'Lapangan premium dengan rumput sintetis standar WPT, atap kanopi, '
  'pencahayaan LED anti-silau, dan area lounge yang nyaman.',
  'Jl. Kartini Raya No.12, Depok, Kec. Pancoran Mas, Kota Depok, Jawa Barat',
  150000, 4.9, 214, 2.4, 'Premium',
  'assets/images/court_main.jpg',
  '{locker,ac,parking,racketRental,cafe,shower,wifi,mushola}'
)
on conflict do nothing;
