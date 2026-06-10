# KaamAsaan Supabase Backend Development

This folder contains the first backend planning package for KaamAsaan. It is intentionally separate from the React Native and web frontend code.

## Why Supabase

Supabase provides:

- PostgreSQL for structured solar catalog, system design, and booking data.
- Supabase Auth for customer, admin, and installer identities.
- Row Level Security (RLS) to protect customer records.
- Private database helper functions and triggers for server-side validation.
- Storage and API capabilities that can be introduced in later phases.
- A practical path from the current mock frontend data to a production backend.

## Folder Contents

- `supabase-sql-schema.sql`: Paste-ready PostgreSQL schema, indexes, private helper functions, validation triggers, and initial RLS policies.
- `seed-data.sql`: Initial brands and inverter-to-battery compatibility rules.
- `database-schema.md`: Human-readable table design and relationships.
- `api-structure.md`: Planned Supabase query/service structure for the mobile app.
- `rls-policies.md`: Security model, implemented policies, and future installer work.
- `future-backend-plan.md`: Suggested implementation phases.
- `migrations/`: Numbered follow-up SQL migrations for an already-running Supabase project.

## How To Apply The SQL

1. Create a Supabase project.
2. Open **SQL Editor** in the Supabase dashboard.
3. Create a new query and paste the contents of `supabase-sql-schema.sql`.
4. Run the query.
5. Create another query and paste the contents of `seed-data.sql`.
6. Run the seed query.
7. Open **Table Editor** and verify the tables and seed brands.

## Included Tables

- `profiles`
- `brands`
- `products`
- `product_compatibility`
- `system_designs`
- `survey_bookings`
- `smart_tool_results`

## Important Notes

- The mobile frontend is not connected yet.
- Admin access depends on a user having a `profiles` row with `role = 'admin'`.
- Customer profile edits cannot change the protected `role` field.
- New Supabase Auth users automatically receive a customer `profiles` row through the `on_auth_user_created` trigger.
- Keep the `private` schema out of the Supabase Dashboard API-exposed schemas list. It contains database-only authorization helpers.
- Products are intentionally not seeded yet because verified models, specs, pricing, and image URLs should be reviewed before publishing.
- `supabase-sql-schema.sql` is the initial fresh-project migration. If it has already been applied to a Supabase project, add a numbered follow-up migration instead of rerunning edited schema sections manually.
- Existing projects should run `migrations/001_add_survey_booking_reference_code.sql` once to enable customer-friendly survey references.
- Existing projects should run `migrations/002_expand_survey_booking_status_workflow.sql` once to enable the full survey-to-installation journey.
- Test the signup trigger in a development Supabase project first. Supabase Auth triggers can block signup if a trigger function fails.

## Next Phase

The next backend phase should add verified product seed data, Supabase Storage buckets, frontend environment configuration, typed API services, and booking submission integration. Orders, payments, installer assignments, and notifications should be introduced as dedicated follow-up migrations after their workflows are confirmed.
