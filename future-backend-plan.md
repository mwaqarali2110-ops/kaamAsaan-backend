# Future Backend Plan

## Phase 1: Supabase Foundation

- Create Supabase project.
- Run `supabase-sql-schema.sql`.
- Run `seed-data.sql`.
- Create the first admin Auth user and set its profile role.
- Test signup and automatic profile creation.
- Review RLS policies in the dashboard.

## Phase 2: Auth And Profiles

- Add phone OTP or email authentication based on product requirements.
- Confirm whether profile edits use direct RLS updates or a narrower RPC.
- Define admin and installer onboarding flows.

## Phase 3: Marketplace Catalog

- Confirm verified product models, prices, specifications, and compatibility rules.
- Add product seed scripts.
- Create Supabase Storage buckets for brand logos, product images, and datasheets.
- Add admin catalog operations.
- Add category-specific product validation and search filters to the admin UI.

## Phase 4: Mobile Integration

- Add Supabase client configuration to the Expo project.
- Create typed service wrappers and React Query hooks.
- Replace mock marketplace catalog data.
- Save calculator results and system designs.
- Submit survey and maintenance bookings.

## Phase 5: Operational Workflow

- Add `installer_profiles`, `booking_assignments`, and installer availability/service-area data.
- Add service tracking events and report uploads.
- Add server-controlled booking status transitions.
- Add `notifications` and `notification_preferences`.
- Add push, SMS, and WhatsApp provider integrations behind Edge Functions.
- Add preventive maintenance memberships and service history.

## Phase 6: Orders And Payments

- Add `orders`, `order_items`, and `order_status_history`.
- Snapshot product names, SKU, quantity, and price into order items.
- Calculate totals server-side.
- Add `payment_transactions` and immutable `payment_webhook_events`.
- Verify payment provider webhooks in Edge Functions.
- Add admin reconciliation, refund, and cancellation workflows.

## Phase 7: Production Hardening

- Add validation RPCs for component compatibility.
- Audit all RLS policies with test users.
- Add environment separation for development, staging, and production.
- Add `audit_logs` for privileged admin and operational actions.
- Add backups, observability, rate limiting, and webhook idempotency.
