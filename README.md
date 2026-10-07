# bengkelflutter — Bengkel Paten Mobile Client

Production-oriented Flutter client untuk Laravel Bengkel backend.
Bukan demo. Backend adalah single source of truth.

- Backend repo: https://github.com/linducip2208/bengkel (jangan dimodifikasi dari task ini)
- Flutter repo: https://github.com/linducip2208/bengkelflutter
- Kontrak: `D:\project laravel\bengkel\docs\FLUTTER-API-CONTRACT.md` (110 routes `/api/v1`, read-only dari sini)

## Requirements

Flutter 3.41.6 / Dart 3.11.4 (stable), Android SDK 36, JDK 17+.
`flutter doctor`, `flutter devices` untuk target. Firebase opsional (push-ready).

## Setup

```powershell
flutter pub get
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://bengkel-paten.local/api/v1
```

Staging/prod:

```powershell
flutter run --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://staging.example.com/api/v1
flutter run --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://bengkel.example.com/api/v1
```

Lihat `.env.example`. Jangan commit secret, keystore, `.env`, `google-services.json`.

## Architecture

```
lib/app        router (go_router + guard), theme, config, providers, branch_net
lib/core       network (Dio), error, storage (secure/prefs/cache), security, utils (fmt/log), widgets
lib/data       datasources remote (auth/branch/generic/photo/device/POS/health), repositories
lib/domain     entities (user/branch/roles)
lib/features   auth/dashboard/bookings/customers/vehicles/checkin/inspection/findings/
               estimates/approvals/workorders/tasks/technicians/inventory/qc/
               invoices/payments/pos/notifications/misc offline
lib/l10n       Tr (id/en)
lib/shared     design system
```

State: Riverpod. Logic di VM/repo, bukan widget. HTTP/SQLite tidak dari widget.

## Authentication & roles

Sanctum Bearer di `flutter_secure_storage`. 401 → logout + hapus token + clear cabang.
Roles: super_admin/admin/manager/service_advisor/mekanik/kasir/inventory.
UI guard hanya UX; server otoritatif. Logout bersihkan kredensial + cache user.

## Branch

`GET /branches` = cabang akses. Tanpa assignment = DENIED eksplisit.
Ganti cabang → refetch; jangan tampilkan stale. Lintas cabang = 404, manipulasi = 403.

## Offline & sync

SQLite `bengkel_sync.db` queue: id/operation/entity/entity_id/payload/created_at/
attempts/last_error/status (PENDING/SYNCING/SUCCESS/FAILED/CONFLICT).
Backoff eksponensial, idempotency_key uuid. Server-wins untuk finansial/
inventory/approval/payment — pull GET rekonsiliasi setelah online.
Banner ONLINE/OFFLINE. Cache baca + last-synced + draft form panjang.

## Testing

```powershell
flutter test
```

Unit (models/roles/sync/error), widget (login/badge/guard), security
(token/logout/branch/validation), offline (queue/backoff/server-wins),
critical mutations (online/offline/error/auth/retry/duplicate, mock Dio),
integration `integration_test/workshop_e2e_test.dart` (butuh staging → bila
tanpa infra laporkan NOT EXECUTED, bukan PASSED).

## Android / iOS / release

- App ID `com.bengkelpaten.bengkelflutter`, label Bengkel Paten, v1.0.0+1
- Android: INTERNET/NETWORK/CAMERA/NOTIF/MEDIA, desugaring, deep link `bengkelpaten://app`
- Signing: `android/key.properties.example` → `key.properties` (jangan commit)
- iOS: camera/photo usage, display name; build butuh macOS/Xcode (tidak difabrikasi)
- Ikon/splash: netral profesional; ganti di `android/app/src/main/res/mipmap-*`,
  `ios/Runner/Assets.xcassets/AppIcon.appiconset`, `android/app/src/main/res/drawable/launch_background.xml`

```powershell
flutter build apk --release
flutter build appbundle --release
```

## Troubleshooting

- 422 tanpa payment_date → kirim `payment_date YYYY-MM-DD` (wajib server)
- stock-adjust 422 → body `{quantity, type, notes?}`
- vehicle 422 → wajib `customer_id, vehicle_type_id, vehicle_brand_id, fuel_type_id, number_plate`
- jobcard 422 → wajib `customer_id, vehicle_id, title, service_date`
- POS 422/403 → butuh `session_id` valid + role diskon admin/manager

## Security

Token secure-only, tanpa log password/token/secret, logout cleanup,
isolasi cache per-user/cabang, validasi deep link & upload (jpeg/png/webp ≤5MB),
tanpa TLS bypass. Lihat `docs/SECURITY.md`.

## Folder structure & docs

`docs/ARCHITECTURE, API-INTEGRATION, OFFLINE-SYNC, SECURITY, TESTING, RELEASE,
ROLE-MATRIX, TRACEABILITY, FINAL-AUDIT, ui-ux (baru)`. Kontrak per-endpoint +
`CONTRACT TO VERIFY` bila ragu (saat ini tidak ada — terverifikasi 2026-10-07).
