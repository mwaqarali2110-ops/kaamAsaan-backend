-- Extend the existing enum in place so current pending, confirmed, completed,
-- and cancelled rows continue to work without data rewrites.
alter type public.booking_status add value if not exists 'survey_scheduled';
alter type public.booking_status add value if not exists 'survey_completed';
alter type public.booking_status add value if not exists 'proposal_preparation';
alter type public.booking_status add value if not exists 'quotation_shared';
alter type public.booking_status add value if not exists 'installation_planning';
alter type public.booking_status add value if not exists 'installation_completed';

-- `completed` remains available as a legacy alias for previously completed
-- survey rows. New admin updates should use the explicit workflow statuses.

