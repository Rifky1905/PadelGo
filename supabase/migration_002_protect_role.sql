-- ============================================================
-- Migrasi 002 — Role admin tidak bisa diambil sendiri oleh user
-- ============================================================

-- 1. Registrasi selalu membuat role 'user' (metadata 'role' diabaikan)
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

-- 2. User biasa tidak boleh mengubah kolom role miliknya
--    (SQL Editor / service role: auth.uid() null → tetap diizinkan)
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
