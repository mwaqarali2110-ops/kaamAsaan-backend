-- KaamAsaan marketplace catalog import: market-rate products
-- Run after supabase-sql-schema.sql and seed-data.sql.
-- Safe to rerun: brands are upserted by (name, category), products by slug.

begin;

-- A company can appear in multiple catalog categories because brands.category
-- is intentionally category-specific in the current schema.
insert into public.brands (name, slug, category, is_active)
values
  ('Canadian Solar', 'canadian-solar', 'solar_panel', true),
  ('Jinko Solar', 'jinko-solar', 'solar_panel', true),
  ('Astro Solar', 'astro-solar', 'solar_panel', true),
  ('JA Solar', 'ja-solar', 'solar_panel', true),
  ('Longi', 'longi', 'solar_panel', true),
  ('AIKO Solar', 'aiko-solar', 'solar_panel', true),
  ('Risen Solar', 'risen-solar', 'solar_panel', true),
  ('Jesko Solar', 'jesko-solar', 'solar_panel', true),
  ('Growatt', 'growatt-inverter', 'inverter', true),
  ('GoodWe', 'goodwe-inverter', 'inverter', true),
  ('Solis', 'solis-inverter', 'inverter', true),
  ('SAJ', 'saj-inverter', 'inverter', true),
  ('Crown', 'crown-inverter', 'inverter', true),
  ('Inverex', 'inverex-inverter', 'inverter', true),
  ('Huawei', 'huawei-inverter', 'inverter', true),
  ('GoodWe', 'goodwe-battery', 'battery', true),
  ('Crown', 'crown-battery', 'battery', true),
  ('Huawei', 'huawei-battery', 'battery', true),
  ('Chint', 'chint-accessory', 'accessory', true),
  ('Epever', 'epever-accessory', 'accessory', true)
on conflict (name, category) do update
set is_active = excluded.is_active,
    updated_at = now();

with catalog (
  brand_name,
  category,
  name,
  slug,
  sku,
  model,
  capacity_watt,
  capacity_kw,
  price,
  warranty_years,
  description,
  specifications,
  stock_status
) as (
  values
    (
      'Canadian Solar', 'solar_panel', 'Canadian Solar N Type BF 590W',
      'canadian-solar-n-type-bf-590w', 'KA-PNL-CS-NBF-590', 'N Type BF 590W',
      590, null::numeric, (590 * 47.0)::numeric, null::numeric,
      'Canadian Solar N-Type bifacial module for efficient residential and commercial solar systems.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":47}'::jsonb,
      'in_stock'
    ),
    (
      'Canadian Solar', 'solar_panel', 'Canadian Solar N Type BF 635W',
      'canadian-solar-n-type-bf-635w', 'KA-PNL-CS-NBF-635', 'N Type BF 635W',
      635, null::numeric, (635 * 45.5)::numeric, null::numeric,
      'Canadian Solar high-output N-Type bifacial module for projects requiring fewer panels.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":45.5}'::jsonb,
      'in_stock'
    ),
    (
      'Canadian Solar', 'solar_panel', 'Canadian Solar N Type BF 615W',
      'canadian-solar-n-type-bf-615w', 'KA-PNL-CS-NBF-615', 'N Type BF 615W',
      615, null::numeric, (615 * 45.5)::numeric, null::numeric,
      'Canadian Solar N-Type bifacial module with balanced output for modern solar installations.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":45.5}'::jsonb,
      'in_stock'
    ),
    (
      'Canadian Solar', 'solar_panel', 'Canadian Solar N Type BF 620W',
      'canadian-solar-n-type-bf-620w', 'KA-PNL-CS-NBF-620', 'N Type BF 620W',
      620, null::numeric, (620 * 45.5)::numeric, null::numeric,
      'Canadian Solar N-Type bifacial module suited to high-efficiency rooftop and commercial systems.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":45.5}'::jsonb,
      'in_stock'
    ),
    (
      'Jinko Solar', 'solar_panel', 'Jinko Solar N Type BF 590W',
      'jinko-solar-n-type-bf-590w', 'KA-PNL-JK-NBF-590', 'N Type BF 590W',
      590, null::numeric, (590 * 45.5)::numeric, null::numeric,
      'Jinko Solar N-Type bifacial module with reliable generation performance.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":45.5}'::jsonb,
      'in_stock'
    ),
    (
      'Jinko Solar', 'solar_panel', 'Jinko Solar N Type BF 620W',
      'jinko-solar-n-type-bf-620w-limited-stock', 'KA-PNL-JK-NBF-620-LS', 'N Type BF 620W',
      620, null::numeric, (620 * 45.0)::numeric, null::numeric,
      'Jinko Solar N-Type bifacial module available in a limited-stock batch.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":45,"stock_note":"Limited stock batch: x20 panels available."}'::jsonb,
      'in_stock'
    ),
    (
      'Astro Solar', 'solar_panel', 'Astro Solar N Type BF 625W',
      'astro-solar-n-type-bf-625w', 'KA-PNL-AS-NBF-625', 'N Type BF 625W',
      625, null::numeric, (625 * 43.5)::numeric, null::numeric,
      'Astro Solar N-Type bifacial panel offering practical high-output performance.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":43.5}'::jsonb,
      'in_stock'
    ),
    (
      'Astro Solar', 'solar_panel', 'Astro Solar N Type BF 720W',
      'astro-solar-n-type-bf-720w', 'KA-PNL-AS-NBF-720', 'N Type BF 720W',
      720, null::numeric, (720 * 42.5)::numeric, null::numeric,
      'Astro Solar high-capacity N-Type bifacial panel for large-output installations.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":42.5}'::jsonb,
      'in_stock'
    ),
    (
      'JA Solar', 'solar_panel', 'JA Solar N Type BF 715W Dated Stock',
      'ja-solar-n-type-bf-715w-dated-stock', 'KA-PNL-JA-NBF-715-DS', 'N Type BF 715W',
      715, null::numeric, (715 * 42.5)::numeric, null::numeric,
      'JA Solar N-Type bifacial panel offered from dated stock at a market-rate price.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","rate_per_watt":42.5,"stock_note":"Dated stock."}'::jsonb,
      'in_stock'
    ),
    (
      'Longi', 'solar_panel', 'Longi HiMO X10 BF 645W',
      'longi-himo-x10-bf-645w', 'KA-PNL-LG-X10-BF-645', 'HiMO X10 BF 645W',
      645, null::numeric, (645 * 46.5)::numeric, null::numeric,
      'Longi HiMO X10 premium bifacial module using advanced N-Type ABC technology.',
      '{"product_type":"solar_panel","technology":"Premium N-Type ABC Bifacial","series":"HiMO X10","rate_per_watt":46.5}'::jsonb,
      'in_stock'
    ),
    (
      'Longi', 'solar_panel', 'Longi HiMO X10 Mono 640W',
      'longi-himo-x10-mono-640w', 'KA-PNL-LG-X10-MN-640', 'HiMO X10 Mono 640W',
      640, null::numeric, (640 * 44.0)::numeric, null::numeric,
      'Longi HiMO X10 premium monofacial module using advanced N-Type ABC technology.',
      '{"product_type":"solar_panel","technology":"Premium N-Type ABC Mono","series":"HiMO X10","rate_per_watt":44}'::jsonb,
      'in_stock'
    ),
    (
      'Longi', 'solar_panel', 'Longi HiMO7 BF 620W',
      'longi-himo7-bf-620w', 'KA-PNL-LG-H7-BF-620', 'HiMO7 BF 620W',
      620, null::numeric, (620 * 43.5)::numeric, null::numeric,
      'Longi HiMO7 bifacial module with dependable high-efficiency energy generation.',
      '{"product_type":"solar_panel","technology":"N-Type Bifacial","series":"HiMO7","rate_per_watt":43.5}'::jsonb,
      'in_stock'
    ),
    (
      'AIKO Solar', 'solar_panel', 'AIKO Solar N Type BF 650W',
      'aiko-solar-n-type-bf-650w', 'KA-PNL-AK-ABC-BF-650', 'N Type BF 650W',
      650, null::numeric, (650 * 43.5)::numeric, null::numeric,
      'AIKO Solar premium ABC bifacial module for high-performance solar installations.',
      '{"product_type":"solar_panel","technology":"Premium ABC Bifacial","rate_per_watt":43.5}'::jsonb,
      'in_stock'
    ),
    (
      'Growatt', 'inverter', 'Growatt SPM 6000TL 6kW IP65 Hybrid Inverter',
      'growatt-spm-6000tl-6kw-ip65-hybrid-inverter', 'KA-INV-GR-SPM6000TL', 'SPM 6000TL',
      null::integer, 6.00, 210000::numeric, 10::numeric,
      'Growatt single-phase hybrid inverter with dual output and IP65 protection.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid Dual Output","phase":"single_phase","ip_rating":"IP65","series":"SPM","warranty_note":"10 years warranty"}'::jsonb,
      'in_stock'
    ),
    (
      'Growatt', 'inverter', 'Growatt SPM 8000TL 8kW IP65 Hybrid Inverter',
      'growatt-spm-8000tl-8kw-ip65-hybrid-inverter', 'KA-INV-GR-SPM8000TL', 'SPM 8000TL',
      null::integer, 8.00, 310000::numeric, 10::numeric,
      'Growatt single-phase hybrid inverter with dual output and IP65 protection.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid Dual Output","phase":"single_phase","ip_rating":"IP65","series":"SPM","warranty_note":"10 years warranty"}'::jsonb,
      'in_stock'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 6kW Hybrid 1-Phase Inverter',
      'goodwe-6kw-hybrid-1-phase-inverter', 'KA-INV-GW-HYB-1P-06', 'GoodWe 6kW Hybrid 1-Phase',
      null::integer, 6.00, 245000::numeric, null::numeric,
      'GoodWe single-phase hybrid inverter for residential solar and battery systems.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"single_phase"}'::jsonb,
      'in_stock'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 12kW Hybrid 1-Phase Inverter',
      'goodwe-12kw-hybrid-1-phase-inverter', 'KA-INV-GW-HYB-1P-12', 'GoodWe 12kW Hybrid 1-Phase',
      null::integer, 12.00, 430000::numeric, null::numeric,
      'GoodWe high-capacity single-phase hybrid inverter for larger residential loads.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"single_phase"}'::jsonb,
      'in_stock'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 12kW Hybrid 3-Phase Inverter',
      'goodwe-12kw-hybrid-3-phase-inverter', 'KA-INV-GW-HYB-3P-12', 'GoodWe 12kW Hybrid 3-Phase',
      null::integer, 12.00, null::numeric, 5::numeric,
      'GoodWe three-phase hybrid inverter available on request for commercial and large-home systems.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"three_phase","warranty_note":"5 years warranty"}'::jsonb,
      'on_request'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 15kW Hybrid 3-Phase Inverter',
      'goodwe-15kw-hybrid-3-phase-inverter', 'KA-INV-GW-HYB-3P-15', 'GoodWe 15kW Hybrid 3-Phase',
      null::integer, 15.00, null::numeric, 5::numeric,
      'GoodWe three-phase hybrid inverter available on request for larger solar systems.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"three_phase","warranty_note":"5 years warranty"}'::jsonb,
      'on_request'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 20kW Hybrid 3-Phase Inverter',
      'goodwe-20kw-hybrid-3-phase-inverter', 'KA-INV-GW-HYB-3P-20', 'GoodWe 20kW Hybrid 3-Phase',
      null::integer, 20.00, 810000::numeric, 5::numeric,
      'GoodWe three-phase hybrid inverter for high-capacity installations.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"three_phase","warranty_note":"5 years warranty"}'::jsonb,
      'in_stock'
    ),
    (
      'GoodWe', 'inverter', 'GoodWe 50kW HV Hybrid 3-Phase Inverter',
      'goodwe-50kw-hv-hybrid-3-phase-inverter', 'KA-INV-GW-HV-3P-50', 'GoodWe 50kW HV Hybrid 3-Phase',
      null::integer, 50.00, 1450000::numeric, 5::numeric,
      'GoodWe high-voltage three-phase hybrid inverter for commercial solar projects.',
      '{"product_type":"hybrid_inverter","technology":"HV Hybrid","phase":"three_phase","voltage":"high_voltage","warranty_note":"5 years warranty"}'::jsonb,
      'in_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 8kW Plus Hybrid Inverter',
      'solis-8kw-plus-hybrid-inverter', 'KA-INV-SL-PLUS-08', 'Solis 8kW Plus Hybrid',
      null::integer, 8.00, 335000::numeric, null::numeric,
      'Solis Plus series single-phase hybrid inverter for residential backup systems.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"single_phase","series":"Plus"}'::jsonb,
      'in_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 10kW Plus Hybrid Inverter',
      'solis-10kw-plus-hybrid-inverter', 'KA-INV-SL-PLUS-10', 'Solis 10kW Plus Hybrid',
      null::integer, 10.00, 425000::numeric, null::numeric,
      'Solis Plus series single-phase hybrid inverter for strong residential solar performance.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"single_phase","series":"Plus"}'::jsonb,
      'in_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 12kW Plus Hybrid Inverter',
      'solis-12kw-plus-hybrid-inverter', 'KA-INV-SL-PLUS-12', 'Solis 12kW Plus Hybrid',
      null::integer, 12.00, 470000::numeric, null::numeric,
      'Solis Plus series single-phase hybrid inverter for high-capacity home systems.',
      '{"product_type":"hybrid_inverter","technology":"Hybrid","phase":"single_phase","series":"Plus"}'::jsonb,
      'in_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 12kW LV 3P Hybrid Inverter',
      'solis-12kw-lv-3p-hybrid-inverter', 'KA-INV-SL-LV-3P-12', 'Solis 12kW LV 3P Hybrid',
      null::integer, 12.00, null::numeric, null::numeric,
      'Solis low-voltage three-phase hybrid inverter currently out of stock.',
      '{"product_type":"hybrid_inverter","technology":"LV Hybrid","phase":"three_phase","voltage":"low_voltage","stock_note":"Out of stock."}'::jsonb,
      'out_of_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 15kW LV 3P Hybrid Inverter',
      'solis-15kw-lv-3p-hybrid-inverter', 'KA-INV-SL-LV-3P-15', 'Solis 15kW LV 3P Hybrid',
      null::integer, 15.00, null::numeric, null::numeric,
      'Solis low-voltage three-phase hybrid inverter currently out of stock.',
      '{"product_type":"hybrid_inverter","technology":"LV Hybrid","phase":"three_phase","voltage":"low_voltage","stock_note":"Out of stock."}'::jsonb,
      'out_of_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 20kW Hybrid HV Inverter',
      'solis-20kw-hybrid-hv-inverter', 'KA-INV-SL-HV-20', 'Solis 20kW Hybrid HV',
      null::integer, 20.00, 710000::numeric, null::numeric,
      'Solis high-voltage hybrid inverter for demanding three-phase solar systems.',
      '{"product_type":"hybrid_inverter","technology":"HV Hybrid","phase":"three_phase","voltage":"high_voltage"}'::jsonb,
      'in_stock'
    ),
    (
      'Solis', 'inverter', 'Solis 50kW Hybrid HV Inverter',
      'solis-50kw-hybrid-hv-inverter', 'KA-INV-SL-HV-50', 'Solis 50kW Hybrid HV',
      null::integer, 50.00, 1490000::numeric, null::numeric,
      'Solis high-voltage hybrid inverter for commercial and industrial solar installations.',
      '{"product_type":"hybrid_inverter","technology":"HV Hybrid","phase":"three_phase","voltage":"high_voltage"}'::jsonb,
      'in_stock'
    )
)
insert into public.products (
  brand_id,
  category,
  name,
  slug,
  sku,
  model,
  capacity_watt,
  capacity_kw,
  battery_capacity_kwh,
  price,
  currency_code,
  warranty_years,
  description,
  image_url,
  specifications,
  stock_status,
  is_featured,
  is_active
)
select
  brands.id,
  catalog.category::public.product_category,
  catalog.name,
  catalog.slug,
  catalog.sku,
  catalog.model,
  catalog.capacity_watt,
  catalog.capacity_kw,
  null::numeric,
  catalog.price,
  'PKR',
  catalog.warranty_years,
  catalog.description,
  null::text,
  catalog.specifications,
  catalog.stock_status::public.product_stock_status,
  false,
  true
from catalog
join public.brands brands
  on brands.name = catalog.brand_name
 and brands.category = catalog.category::public.product_category
on conflict (slug) do update
set brand_id = excluded.brand_id,
    category = excluded.category,
    name = excluded.name,
    sku = excluded.sku,
    model = excluded.model,
    capacity_watt = excluded.capacity_watt,
    capacity_kw = excluded.capacity_kw,
    battery_capacity_kwh = excluded.battery_capacity_kwh,
    price = excluded.price,
    currency_code = excluded.currency_code,
    warranty_years = excluded.warranty_years,
    description = excluded.description,
    specifications = excluded.specifications,
    stock_status = excluded.stock_status,
    is_active = excluded.is_active,
    updated_at = now();

commit;

