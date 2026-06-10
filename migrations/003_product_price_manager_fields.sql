-- Product Price Manager support fields.
-- Run in Supabase SQL Editor after the base schema and earlier migrations.

alter type public.product_stock_status add value if not exists 'ready_stock';
alter type public.product_stock_status add value if not exists 'eta';
alter type public.product_stock_status add value if not exists 'in_transit';
alter type public.product_stock_status add value if not exists 'booking_open';

do $$ begin
  create type public.product_price_unit as enum ('per_watt', 'total_price');
exception when duplicate_object then null;
end $$;

alter table public.products
  add column if not exists sub_category text,
  add column if not exists capacity_value numeric(12, 2) check (capacity_value is null or capacity_value > 0),
  add column if not exists capacity_unit text,
  add column if not exists price_unit public.product_price_unit not null default 'total_price',
  add column if not exists rate_per_watt numeric(12, 2) check (rate_per_watt is null or rate_per_watt >= 0),
  add column if not exists eta_note text,
  add column if not exists warranty text,
  add column if not exists is_visible boolean not null default true;

update public.products
set
  sub_category = case
    when sub_category is not null then sub_category
    when category = 'battery' then 'lithium_battery'
    when category = 'inverter' and (name ilike '%on-grid%' or name ilike '%on grid%' or model ilike '%on-grid%' or model ilike '%on grid%') then 'on_grid_inverter'
    when category = 'inverter' then 'hybrid_inverter'
    when category = 'accessory' and name ilike '%combo%' then 'combo_deal'
    when category = 'accessory' and name ilike '%ess%' then 'ess'
    when category = 'accessory' then 'accessory'
    else sub_category
  end,
  capacity_value = coalesce(capacity_value, capacity_watt::numeric, capacity_kw, battery_capacity_kwh),
  capacity_unit = coalesce(
    capacity_unit,
    case
      when capacity_watt is not null then 'W'
      when capacity_kw is not null then 'kW'
      when battery_capacity_kwh is not null then 'kWh'
      else null
    end
  ),
  price_unit = case
    when category = 'solar_panel' then 'per_watt'::public.product_price_unit
    else coalesce(price_unit, 'total_price'::public.product_price_unit)
  end,
  rate_per_watt = case
    when category = 'solar_panel' and rate_per_watt is null and capacity_watt is not null and price is not null then round(price / capacity_watt, 2)
    else rate_per_watt
  end,
  warranty = coalesce(warranty, case when warranty_years is not null then warranty_years::text || ' years' else null end),
  is_visible = coalesce(is_visible, is_active);

create index if not exists idx_products_price_manager_filters
  on public.products(category, sub_category, brand_id, stock_status, is_visible);
