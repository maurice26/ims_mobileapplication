# Copilot Instructions for IMS Mobile App

- Project layout:
  - `ims_mobileapp/` contains the Flutter app.
  - `ims_mobileapp/inventory_management_system/` contains the ASP.NET backend and GraphQL server.

- Key architecture:
  - Flutter uses Riverpod state management with `authProvider` for login state and role access.
  - Auth token and user are persisted in `lib/services/auth_service.dart` using secure storage.
  - `lib/widgets/role_guard.dart` protects screens by required role and returns `LoginScreen` when unauthenticated.
  - `lib/config.dart` resolves backend URLs for web, Android emulator (`10.0.2.2`), physical devices, and `--dart-define=API_BASE_URL=...` overrides.

- API integration:
  - Authentication uses REST via `lib/services/api_service.dart`:
    - `ApiService.login` → `/api/auth/login`
    - `ApiService.register` → `/api/auth/register`
  - All CRUD operations use GraphQL through `lib/services/graphql_service.dart` and service classes like `user_service.dart`, `product_service.dart`, `supplier_service.dart`, `sales_service.dart`, `payment_service.dart`, `report_service.dart`.
  - Backend GraphQL server is configured in `inventory_management_system/Program.cs` at `/graphql` with CORS `AllowAll` and JWT auth.

- Important GraphQL operations to preserve:
  - `GetUsers`, `CreateUser`, `UpdateUser`, `DeleteUser`
  - `GetProducts`, `CreateProduct`, `UpdateProduct`, `DeleteProduct`
  - `GetSuppliers`, `CreateSupplier`, `UpdateSupplier`, `DeleteSupplier`
  - `GetSales`, `CreateSale`
  - `GetPayments`, `AddPayment`
  - `ExportSalesCsv`, `GetReceipt`

- UI patterns:
  - Use `lib/widgets/datagrid/ims_table.dart` for table-style lists with responsive fallback to cards on narrow screens.
  - Use `lib/widgets/datagrid/ims_table_row_actions.dart` for edit/delete actions with tooltip/hover support.
  - Use `lib/widgets/app_shell/page_wrapper.dart` for page layout and section subtitle consistency.
  - `lib/widgets/role_drawer.dart` implements role-specific navigation tiles.

- Developer workflow:
  - Run `flutter pub get`
  - Run `flutter analyze`
  - Run `flutter test`
  - Use `flutter run -d chrome` or `flutter run` for manual UI testing.
  - Backend should be started from `ims_mobileapp/inventory_management_system/` with `dotnet run` and should expose GraphQL at `http://localhost:7188/graphql`.

- Project-specific conventions:
  - Model roles are normalized to lowercase in `lib/models/user.dart` but widget access checks use canonical names in `RoleGuard`.
  - Provider results are refreshed by invalidating `FutureProvider`s after create/update/delete.
  - The app is built as role-based dashboards: `AdminDashboard`, `SalesDashboard`, and `UserDashboard`.

- What to watch for:
  - Do not add new backend endpoints without matching GraphQL operations and token handling.
  - Avoid duplicating page wrappers; reuse `PageWrapper` and the theme from `lib/core/theme/app_theme.dart`.
  - Keep button/field styling consistent with existing Material 3 theming and rounded cards.

> If any section is unclear or incomplete, please tell me which part to expand or refine.