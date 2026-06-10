-- KaamAsaan initial catalog seed data
-- Run after supabase-sql-schema.sql.

begin;

insert into public.brands (name, slug, category)
values
  ('JA Solar', 'ja-solar', 'solar_panel'),
  ('Astronergy', 'astronergy', 'solar_panel'),
  ('Yingli', 'yingli', 'solar_panel'),
  ('Fox', 'fox-inverter', 'inverter'),
  ('GoodWe', 'goodwe-inverter', 'inverter'),
  ('Solis', 'solis-inverter', 'inverter'),
  ('Fox', 'fox-battery', 'battery'),
  ('GoodWe', 'goodwe-battery', 'battery'),
  ('Soluna', 'soluna-battery', 'battery'),
  ('Dyness', 'dyness-battery', 'battery'),
  ('Pylontech', 'pylontech-battery', 'battery'),
  ('Elevated Structure', 'elevated-structure', 'mounting_structure')
on conflict (name, category) do update
set slug = excluded.slug,
    is_active = true;

insert into public.product_compatibility (
  inverter_brand_id,
  compatible_battery_brand_id,
  notes
)
select inverter.id, battery.id, rules.notes
from (
  values
    ('Fox', 'Fox', 'Fox inverter supports Fox batteries only.'),
    ('GoodWe', 'GoodWe', 'GoodWe inverter supports GoodWe batteries.'),
    ('GoodWe', 'Soluna', 'GoodWe inverter supports Soluna batteries.'),
    ('GoodWe', 'Dyness', 'GoodWe inverter supports Dyness batteries.'),
    ('Solis', 'Soluna', 'Solis inverter supports Soluna batteries.'),
    ('Solis', 'Dyness', 'Solis inverter supports Dyness batteries.'),
    ('Solis', 'Pylontech', 'Solis inverter supports Pylontech batteries.')
) as rules(inverter_name, battery_name, notes)
join public.brands inverter
  on inverter.name = rules.inverter_name
 and inverter.category = 'inverter'
join public.brands battery
  on battery.name = rules.battery_name
 and battery.category = 'battery'
on conflict (inverter_brand_id, compatible_battery_brand_id) do update
set notes = excluded.notes,
    is_active = true;

commit;
