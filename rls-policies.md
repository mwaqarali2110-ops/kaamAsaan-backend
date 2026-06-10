# Row Level Security Policies

## Security Model

All application tables enable Row Level Security (RLS). The schema creates `private.is_admin()` as a `SECURITY DEFINER` helper so admin policies can check the signed-in user's profile without recursive RLS issues. Authorization helpers live outside the exposed `public` API schema.

## Implemented Policies

### Profiles

- Authenticated users can read their own profile.
- Authenticated users can update their own profile.
- Admins can read, insert, update, and delete profiles.

### Brands, Products, Compatibility

- Active brands and products are publicly readable by anonymous and authenticated users.
- Compatibility rules are publicly readable.
- Only admins can create, update, or delete catalog records.

### System Designs

- Customers can create records where `user_id = auth.uid()`.
- Customers can read their own designs.
- Customers can update or delete their own draft/design records.
- Admins can manage all designs.

### Survey Bookings

- Customers can create records where `user_id = auth.uid()` and `status = 'pending'`.
- Customers can read their own bookings.
- Admins can manage all bookings.

### Smart Tool Results

- Customers can create records where `user_id = auth.uid()`.
- Customers can read their own results.
- Admins can manage all results.

## Future Installer Policy

Installer access is deferred. A later phase should add:

- `installer_profiles` and a separate `booking_assignments` history table.
- Installer policy allowing read access only to assigned future or active bookings.
- Restricted fields if customer contact details require additional privacy controls.
- Server-side status transition functions so installers cannot write arbitrary booking statuses.

## Profile Role Protection

The schema includes a `protect_profile_role_before_update` trigger. Customers and installers can update their own contact fields, but only admins can change a profile `role`.

## Additional Security Notes

- Public catalog reads return active brands, products, and compatibility rules only.
- Keep the `private` schema out of the Supabase Dashboard API-exposed schemas list. It is for database-only authorization helpers.
- `(select auth.uid())` and `(select private.is_admin())` are used in policies to avoid repeated function evaluation per row.
- Signup profile creation, timestamps, and category validation run through database triggers.
- Orders and payments must use server-side Edge Functions and webhook verification when introduced.
