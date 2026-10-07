# Auth / Authorization / Branch / Offline / Sync (ringkas)

## Authentication

Sanctum PAT Bearer. Login → simpan secure storage → `Authorization` otomatis.
401 (expired/revoke) → logout + hapus token + clear cabang + reset state.
Tidak ada register/forgot/2FA publik (API tidak menyediakan) — user via admin web.
Throttle login 10/mnt. Lihat `AuthRemote`, `AuthVM`, guard go_router.

## Authorization

Roles: super_admin, admin, manager, service_advisor, mekanik, kasir, inventory.
`Roles.*` + `RoleGuard`/`FeatureGate` hanya UX. Server otoritatif (403/404).
Matriks: `docs/ROLE-MATRIX.md`.

## Branch

`GET /branches` = akses user. Pilih → simpan prefs non-sensitif → refetch/invalidate
(customers/vehicles/products/master). Tanpa assignment = DENIED eksplisit.
Lintas cabang 404; manipulasi branch_id 403. Logout/ganti user → clear.

## Offline

Cache baca (SharedPreferences JSON + last-synced) + SQLite queue
`bengkel_sync.db` (queue{id,operation,entity,entity_id,payload,created_at,
attempts,last_error,status}, cache_kv). Banner ONLINE/OFFLINE/SYNCING.
Draft form panjang (inspeksi/finding/estimate/task) survive back/background/restart.

## Sync & konflik

Backoff 2^attempts (cap 60s). Idempotency uuid untuk payment/POS.
Server-wins finansial/inventory/approval/payment/task/QC: POST → GET detail
rekonsiliasi → tampilkan server. Konflik diekspos, tidak dioverwrite diam-diam.
