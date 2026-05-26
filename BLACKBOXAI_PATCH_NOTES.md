# BLACKBOXAI_PATCH_NOTES

## Web crash: Floating SnackBar presented off screen
- Root cause: `SnackBarThemeData.behavior = SnackBarBehavior.floating` in `lib/core/theme/app_theme.dart`.
- Fix applied: changed default snack bar behavior to `SnackBarBehavior.fixed`.

## Notes
- This prevents the `Floating SnackBar presented off screen` assertion during initial web rendering.

