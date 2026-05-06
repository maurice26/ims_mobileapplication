# IMS Flutter App Completion TODO
Status: Approved plan - completing 3-role app (Admin full, Sales limited, User view-only)

## Steps (sequential):
1. [x] Enhance core auth/roles: Complete (user/auth_state/service fixed, role_drawer/main polished).
2. [ ] Guard screens: Started - manage_users.dart & admin_dashboard.dart wrapped with RoleGuard('admin'). Continue others.
3. [x] Complete GraphQL mutations: Created user_service.dart with CRUD, updated user_provider.dart (getUsers works). Backend matches. Added user.roleDisplay. Next: more services.
4. [ ] Upgrade providers to notifiers (CRUD) in all *_provider.dart.
5. [ ] Polish screens: Forms, deletes, loading/error states.
6. [ ] Update main.dart routes + app-wide polish.
7. [ ] Test & complete: flutter test, manual role tests.

Current: Starting step 1.
After all: Run `cd ims_mobileapp && flutter pub get && flutter run`

