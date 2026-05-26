# TODO

## Fix runtime crash on web (Floating SnackBar presented off screen)
- Identify the widget causing the floating SnackBar off-screen error.
- Update SnackBar usage to avoid `SnackBarBehavior.floating` (or constrain floatingAction/bottomNavigation).
- Apply fix in `AdminDashboard` and/or theme where floating SnackBar is set.

## Verify GraphQL 400 Bad Request
- Inspect GraphQL queries/mutations for Payments/Sales.
- Ensure server expects correct variable types and field names.
- Add better error display for GraphQL errors.


