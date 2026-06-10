# API Structure Plan

Supabase exposes PostgreSQL tables through its client SDK. The mobile app should wrap those calls in service modules rather than querying Supabase directly from screens.

## Proposed Mobile Service Modules

```text
src/services/supabase/
  client.ts
  auth.api.ts
  profiles.api.ts
  catalog.api.ts
  compatibility.api.ts
  system-designs.api.ts
  survey-bookings.api.ts
  smart-tools.api.ts
  admin.api.ts
```

## Catalog Queries

### Brands

- List active brands by category.
- Fetch one brand.

### Products

- List active products by category.
- List products by brand.
- Fetch one product.
- Filter by capacity, price, or active category.

### Compatibility

- Fetch approved battery brands for an inverter brand.
- Validate selected inverter and battery brand pairing.

## Customer Queries

### Profiles

- Read signed-in customer's profile.
- Update signed-in customer's name, phone, and city.

### System Designs

- Save a completed or draft design.
- Read signed-in customer's designs.
- Fetch one design owned by the signed-in customer.
- Update or archive a signed-in customer's draft.

### Survey Bookings

- Create a survey or service booking.
- Read signed-in customer's bookings.
- Fetch the customer's latest active booking for the Home journey tracker until installation is completed or the request is cancelled.
- Display the generated customer-facing `reference_code` without exposing internal workflow logic.

### Smart Tool Results

- Save calculator input and output.
- Read signed-in customer's result history.

## Server-Side Validation

The database currently enforces:

- Product category matches brand category.
- Compatibility rules connect inverter brands to battery brands only.
- Saved system component IDs reference the correct product categories.
- Referenced booking designs belong to the booking customer.
- Customer-created bookings start as `pending`.
- Customer profile edits cannot promote `role`.

Use SQL functions or Edge Functions for future multi-step actions such as checkout creation, payment verification, installer assignment, and booking status transitions.

## Admin Panel Requirements

Admin catalog management should initially use the Supabase dashboard. A dedicated admin portal should later provide:

- Brand, product, stock, price, and compatibility management.
- Featured product controls and marketplace publishing state.
- Booking queue filters, assignment controls, and status history.
- Order review, payment reconciliation, refunds, and audit history.
- Notification templates and delivery status.
- Installer onboarding, availability, service areas, and performance.

## Planned Expansion Services

```text
src/services/supabase/
  orders.api.ts
  payments.api.ts
  installers.api.ts
  notifications.api.ts
```

Payments should be created and verified server-side through Edge Functions. Do not trust client-submitted totals or payment status.

## Not Connected Yet

This phase intentionally does not modify frontend environment variables, install Supabase packages, or replace mock API services.
