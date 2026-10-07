# bengkelflutter

Mobile Flutter untuk **Bengkel Paten** (Laravel backend).

- Backend: `D:\project laravel\bengkel` — kontrak: `docs/flutter-api-contract.md`
- Base URL: `{APP_URL}/api/v1` (default `http://bengkel-paten.local/api/v1`)
- Auth: Sanctum Bearer, tidak ada register publik. Login `POST /login` → `{user, token}`.
- Lihat `docs/API_CONTRACT.md` (mirror) + `lib/src/core/network/api_endpoints.dart`.

## Alur

```
Laravel → API Contract → Flutter API Client → Auth → Branch/Role
→ Workshop → Inventory → Invoice → Payment → Notification
→ Offline Sync → E2E → Security → Performance → Release
```

## Setup

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=https://bengkel.example.com/api/v1
```

## Struktur

```
lib/src/core/{config,network,storage}   # Dio + endpoints + secure storage
lib/src/features/auth                   # login/me/logout, Riverpod
lib/src/features/branch                 # GET /branches + notifications
lib/src/features/workshop               # estimate approve/reject/decide/convert, task start/pause/finish, QC
lib/src/features/inventory              # products, stock-adjust, suppliers
lib/src/features/invoice                # invoices + pay (idempotency_key uuid) + POS checkout
lib/src/features/offline               # sqflite outbox (server menang)
lib/src/shared                          # RoleGuard
docs/                                   # API_CONTRACT, SECURITY, RELEASE
test/unit + integration_test/           # unit + E2E flow
```

## Aturan penting (dari backend)

- Role: `super_admin, admin, manager, kasir, mekanik, service_advisor, inventory`.
  `super_admin/admin` semua cabang, selain itu wajib assignment — tanpa assignment = DENIED.
- Jangan kirim `branch_id` untuk mengakali (403). ID lintas cabang = 404.
- Estimate: `draft→sent→waiting_approval→approved|partially_approved|rejected`.
- Task: `pending|ready→in_progress⇄paused→completed→qc_pending→qc_passed|qc_failed`. `start` idempoten.
- QC gagal wajib `notes`.
- Payment & POS checkout pakai `idempotency_key` (uuid ≤64). Retry aman, server menang.
- Token di `flutter_secure_storage`, hapus saat logout/401.
- Throttle: login 10/menit, authed 120/menit.
- Upload multipart belum ada di v1. Push FCM roadmap (endpoint belum ada).
