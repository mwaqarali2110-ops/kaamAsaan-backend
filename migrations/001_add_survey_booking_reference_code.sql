-- Adds a short customer-facing reference without changing booking ownership or status logic.
alter table public.survey_bookings
  add column if not exists reference_code text;

update public.survey_bookings
set reference_code = 'KA-' || upper(substr(md5(id::text), 1, 8))
where reference_code is null or btrim(reference_code) = '';

create unique index if not exists idx_survey_bookings_reference_code
  on public.survey_bookings(reference_code);

alter table public.survey_bookings
  drop constraint if exists survey_bookings_reference_code_format;

alter table public.survey_bookings
  add constraint survey_bookings_reference_code_format
  check (reference_code ~ '^KA-[A-F0-9]{8}$');

alter table public.survey_bookings
  alter column reference_code set not null;

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

revoke all on function private.set_survey_booking_reference_code() from public;
