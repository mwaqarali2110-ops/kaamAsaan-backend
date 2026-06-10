-- KaamAsaan initial Supabase schema
-- Run this file first in the Supabase SQL Editor.

create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

do $$ begin
  create type public.user_role as enum ('customer', 'admin', 'installer');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.product_category as enum ('solar_panel', 'inverter', 'battery', 'mounting_structure', 'accessory');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.booking_type as enum ('solar_survey', 'preventive_maintenance', 'installation', 'net_metering');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.booking_status as enum (
    'pending',
    'confirmed',
    'survey_scheduled',
    'survey_completed',
    'proposal_preparation',
    'quotation_shared',
    'installation_planning',
    'installation_completed',
    'cancelled',
    'completed' -- Legacy alias retained for backward compatibility.
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.smart_tool_type as enum ('load_calculator', 'roof_space', 'roi_calculator', 'battery_backup', 'solar_size');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.product_stock_status as enum ('in_stock', 'out_of_stock', 'preorder', 'on_request');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.system_design_status as enum ('draft', 'completed', 'archived');
exception when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  city text,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  category public.product_category not null,
  logo_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name, category)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete restrict,
  category public.product_category not null,
  name text not null,
  slug text not null unique,
  sku text unique,
  model text,
  capacity_watt integer check (capacity_watt is null or capacity_watt > 0),
  capacity_kw numeric(10, 2) check (capacity_kw is null or capacity_kw > 0),
  battery_capacity_kwh numeric(10, 2) check (battery_capacity_kwh is null or battery_capacity_kwh > 0),
  price numeric(14, 2) check (price is null or price >= 0),
  currency_code text not null default 'PKR' check (currency_code ~ '^[A-Z]{3}$'),
  warranty_years numeric(5, 1) check (warranty_years is null or warranty_years >= 0),
  description text,
  image_url text,
  specifications jsonb not null default '{}'::jsonb,
  stock_status public.product_stock_status not null default 'on_request',
  is_featured boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_compatibility (
  id uuid primary key default gen_random_uuid(),
  inverter_brand_id uuid not null references public.brands(id) on delete cascade,
  compatible_battery_brand_id uuid not null references public.brands(id) on delete cascade,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (inverter_brand_id, compatible_battery_brand_id)
);

create table if not exists public.system_designs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  total_load_watts numeric(12, 2) not null default 0 check (total_load_watts >= 0),
  recommended_solar_kw numeric(10, 2) check (recommended_solar_kw is null or recommended_solar_kw >= 0),
  selected_panel_id uuid references public.products(id) on delete set null,
  selected_inverter_id uuid references public.products(id) on delete set null,
  selected_battery_id uuid references public.products(id) on delete set null,
  backup_hours numeric(8, 2) check (backup_hours is null or backup_hours >= 0),
  estimated_price numeric(14, 2) check (estimated_price is null or estimated_price >= 0),
  status public.system_design_status not null default 'draft',
  design_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.survey_bookings (
  id uuid primary key default gen_random_uuid(),
  reference_code text not null check (reference_code ~ '^KA-[A-F0-9]{8}$'),
  user_id uuid not null references auth.users(id) on delete cascade,
  system_design_id uuid references public.system_designs(id) on delete set null,
  full_name text not null,
  phone text not null,
  city text not null,
  address text not null,
  booking_type public.booking_type not null,
  preferred_date date,
  preferred_time_slot text,
  status public.booking_status not null default 'pending',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.smart_tool_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  tool_type public.smart_tool_type not null,
  input_data jsonb not null default '{}'::jsonb,
  result_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_products_category on public.products(category);
create index if not exists idx_products_brand_id on public.products(brand_id);
create index if not exists idx_brands_active_category on public.brands(category) where is_active = true;
create index if not exists idx_products_active_category_brand on public.products(category, brand_id) where is_active = true;
create index if not exists idx_products_active_search on public.products using gin ((coalesce(name, '') || ' ' || coalesce(model, '')) gin_trgm_ops) where is_active = true;
create index if not exists idx_products_specifications_gin on public.products using gin(specifications);
create index if not exists idx_product_compatibility_inverter on public.product_compatibility(inverter_brand_id) where is_active = true;
create index if not exists idx_product_compatibility_battery on public.product_compatibility(compatible_battery_brand_id) where is_active = true;
create index if not exists idx_survey_bookings_user_id on public.survey_bookings(user_id);
create index if not exists idx_survey_bookings_status on public.survey_bookings(status);
create index if not exists idx_survey_bookings_user_created_at on public.survey_bookings(user_id, created_at desc);
create index if not exists idx_survey_bookings_status_created_at on public.survey_bookings(status, created_at desc);
create unique index if not exists idx_survey_bookings_reference_code on public.survey_bookings(reference_code);
create index if not exists idx_smart_tool_results_user_id on public.smart_tool_results(user_id);
create index if not exists idx_smart_tool_results_user_tool_created_at on public.smart_tool_results(user_id, tool_type, created_at desc);
create index if not exists idx_system_designs_user_id on public.system_designs(user_id);
create index if not exists idx_system_designs_user_created_at on public.system_designs(user_id, created_at desc);

-- Used by RLS policies. A SECURITY DEFINER function avoids recursive profile checks.
-- Keep authorization helpers outside the exposed public API schema.
create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'admin'
  );
$$;

revoke all on function private.is_admin() from public;
grant execute on function private.is_admin() to authenticated;

-- Prevent customers and installers from promoting their own profile role.
create or replace function private.protect_profile_role()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.role is distinct from old.role and not private.is_admin() then
    raise exception 'Only admins can change profile roles';
  end if;
  if new.created_at is distinct from old.created_at and not private.is_admin() then
    raise exception 'Only admins can change profile creation timestamps';
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_role_before_update on public.profiles;
create trigger protect_profile_role_before_update
before update on public.profiles
for each row execute function private.protect_profile_role();

-- Maintain updated_at consistently across mutable records.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles
for each row execute function private.set_updated_at();

drop trigger if exists set_brands_updated_at on public.brands;
create trigger set_brands_updated_at before update on public.brands
for each row execute function private.set_updated_at();

drop trigger if exists set_products_updated_at on public.products;
create trigger set_products_updated_at before update on public.products
for each row execute function private.set_updated_at();

drop trigger if exists set_product_compatibility_updated_at on public.product_compatibility;
create trigger set_product_compatibility_updated_at before update on public.product_compatibility
for each row execute function private.set_updated_at();

drop trigger if exists set_system_designs_updated_at on public.system_designs;
create trigger set_system_designs_updated_at before update on public.system_designs
for each row execute function private.set_updated_at();

drop trigger if exists set_survey_bookings_updated_at on public.survey_bookings;
create trigger set_survey_bookings_updated_at before update on public.survey_bookings
for each row execute function private.set_updated_at();

-- Generate short customer-facing references such as KA-98B59FCE.
create or replace function private.set_survey_booking_reference_code()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  candidate text;
begin
  if new.reference_code is null or pg_catalog.btrim(new.reference_code) = '' then
    loop
      candidate := 'KA-' || pg_catalog.upper(
        pg_catalog.substr(
          pg_catalog.md5(new.id::text || pg_catalog.clock_timestamp()::text || pg_catalog.random()::text),
          1,
          8
        )
      );
      exit when not exists (
        select 1 from public.survey_bookings where reference_code = candidate
      );
    end loop;
    new.reference_code := candidate;
  end if;
  return new;
end;
$$;

drop trigger if exists set_survey_booking_reference_code_before_insert on public.survey_bookings;
create trigger set_survey_booking_reference_code_before_insert
before insert on public.survey_bookings
for each row execute function private.set_survey_booking_reference_code();

-- Create a customer profile whenever Supabase Auth creates a user.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, phone, city)
  values (
    new.id,
    nullif(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(coalesce(new.phone, new.raw_user_meta_data ->> 'phone'), ''),
    nullif(new.raw_user_meta_data ->> 'city', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_user();

-- Enforce catalog category consistency at the database boundary.
create or replace function private.validate_product_brand_category()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  brand_category public.product_category;
begin
  select category into brand_category
  from public.brands
  where id = new.brand_id;

  if brand_category is null or brand_category <> new.category then
    raise exception 'Product category must match its brand category';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_product_brand_category_before_write on public.products;
create trigger validate_product_brand_category_before_write
before insert or update of brand_id, category on public.products
for each row execute function private.validate_product_brand_category();

create or replace function private.validate_compatibility_brand_categories()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.brands
    where id = new.inverter_brand_id and category = 'inverter'
  ) then
    raise exception 'inverter_brand_id must reference an inverter brand';
  end if;

  if not exists (
    select 1 from public.brands
    where id = new.compatible_battery_brand_id and category = 'battery'
  ) then
    raise exception 'compatible_battery_brand_id must reference a battery brand';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_compatibility_brand_categories_before_write on public.product_compatibility;
create trigger validate_compatibility_brand_categories_before_write
before insert or update of inverter_brand_id, compatible_battery_brand_id on public.product_compatibility
for each row execute function private.validate_compatibility_brand_categories();

create or replace function private.validate_system_design_products()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.selected_panel_id is not null and not exists (
    select 1 from public.products where id = new.selected_panel_id and category = 'solar_panel'
  ) then
    raise exception 'selected_panel_id must reference a solar panel product';
  end if;

  if new.selected_inverter_id is not null and not exists (
    select 1 from public.products where id = new.selected_inverter_id and category = 'inverter'
  ) then
    raise exception 'selected_inverter_id must reference an inverter product';
  end if;

  if new.selected_battery_id is not null and not exists (
    select 1 from public.products where id = new.selected_battery_id and category = 'battery'
  ) then
    raise exception 'selected_battery_id must reference a battery product';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_system_design_products_before_write on public.system_designs;
create trigger validate_system_design_products_before_write
before insert or update of selected_panel_id, selected_inverter_id, selected_battery_id on public.system_designs
for each row execute function private.validate_system_design_products();

create or replace function private.validate_booking_system_design_owner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.system_design_id is not null and not exists (
    select 1
    from public.system_designs
    where id = new.system_design_id
      and user_id = new.user_id
  ) then
    raise exception 'system_design_id must belong to the booking customer';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_booking_system_design_owner_before_write on public.survey_bookings;
create trigger validate_booking_system_design_owner_before_write
before insert or update of system_design_id, user_id on public.survey_bookings
for each row execute function private.validate_booking_system_design_owner();

revoke all on function private.protect_profile_role() from public;
revoke all on function private.set_updated_at() from public;
revoke all on function private.set_survey_booking_reference_code() from public;
revoke all on function private.handle_new_user() from public;
revoke all on function private.validate_product_brand_category() from public;
revoke all on function private.validate_compatibility_brand_categories() from public;
revoke all on function private.validate_system_design_products() from public;
revoke all on function private.validate_booking_system_design_owner() from public;

alter table public.profiles enable row level security;
alter table public.brands enable row level security;
alter table public.products enable row level security;
alter table public.product_compatibility enable row level security;
alter table public.system_designs enable row level security;
alter table public.survey_bookings enable row level security;
alter table public.smart_tool_results enable row level security;

-- Profiles
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
on public.profiles for select
to authenticated
using (id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "profiles_update_own_or_admin" on public.profiles;
create policy "profiles_update_own_or_admin"
on public.profiles for update
to authenticated
using (id = (select auth.uid()) or (select private.is_admin()))
with check (id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "profiles_admin_insert" on public.profiles;
create policy "profiles_admin_insert"
on public.profiles for insert
to authenticated
with check ((select private.is_admin()));

drop policy if exists "profiles_admin_delete" on public.profiles;
create policy "profiles_admin_delete"
on public.profiles for delete
to authenticated
using ((select private.is_admin()));

-- Public catalog
drop policy if exists "brands_public_read" on public.brands;
create policy "brands_public_read"
on public.brands for select
to anon, authenticated
using (is_active = true);

drop policy if exists "products_public_read" on public.products;
create policy "products_public_read"
on public.products for select
to anon, authenticated
using (is_active = true);

drop policy if exists "compatibility_public_read" on public.product_compatibility;
create policy "compatibility_public_read"
on public.product_compatibility for select
to anon, authenticated
using (
  is_active = true
  and exists (
    select 1
    from public.brands inverter
    join public.brands battery on battery.id = product_compatibility.compatible_battery_brand_id
    where inverter.id = product_compatibility.inverter_brand_id
      and inverter.is_active = true
      and battery.is_active = true
  )
);

-- Admin catalog management
drop policy if exists "brands_admin_manage" on public.brands;
create policy "brands_admin_manage"
on public.brands for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

drop policy if exists "products_admin_manage" on public.products;
create policy "products_admin_manage"
on public.products for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

drop policy if exists "compatibility_admin_manage" on public.product_compatibility;
create policy "compatibility_admin_manage"
on public.product_compatibility for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

-- Customer-owned records
drop policy if exists "system_designs_own_read" on public.system_designs;
create policy "system_designs_own_read"
on public.system_designs for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "system_designs_own_create" on public.system_designs;
create policy "system_designs_own_create"
on public.system_designs for insert
to authenticated
with check (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "system_designs_own_update" on public.system_designs;
create policy "system_designs_own_update"
on public.system_designs for update
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()))
with check (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "system_designs_own_delete" on public.system_designs;
create policy "system_designs_own_delete"
on public.system_designs for delete
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "system_designs_admin_manage" on public.system_designs;
create policy "system_designs_admin_manage"
on public.system_designs for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

drop policy if exists "survey_bookings_own_read" on public.survey_bookings;
create policy "survey_bookings_own_read"
on public.survey_bookings for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "survey_bookings_own_create" on public.survey_bookings;
create policy "survey_bookings_own_create"
on public.survey_bookings for insert
to authenticated
with check (
  (user_id = (select auth.uid()) and status = 'pending')
  or (select private.is_admin())
);

drop policy if exists "survey_bookings_admin_manage" on public.survey_bookings;
create policy "survey_bookings_admin_manage"
on public.survey_bookings for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

drop policy if exists "smart_tool_results_own_read" on public.smart_tool_results;
create policy "smart_tool_results_own_read"
on public.smart_tool_results for select
to authenticated
using (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "smart_tool_results_own_create" on public.smart_tool_results;
create policy "smart_tool_results_own_create"
on public.smart_tool_results for insert
to authenticated
with check (user_id = (select auth.uid()) or (select private.is_admin()));

drop policy if exists "smart_tool_results_admin_manage" on public.smart_tool_results;
create policy "smart_tool_results_admin_manage"
on public.smart_tool_results for all
to authenticated
using ((select private.is_admin()))
with check ((select private.is_admin()));

-- Explicit API privileges. RLS policies still decide which rows are accessible.
grant select on public.brands, public.products, public.product_compatibility to anon, authenticated;

grant select, insert, update, delete
on public.profiles,
   public.brands,
   public.products,
   public.product_compatibility,
   public.system_designs,
   public.survey_bookings,
   public.smart_tool_results
to authenticated;

revoke all on public.profiles, public.system_designs, public.survey_bookings, public.smart_tool_results from anon;
