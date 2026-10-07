# API Integration — Bengkel Paten (verified vs server 2026-10-07)

Sumber: `D:\project laravel\bengkel\docs\FLUTTER-API-CONTRACT.md` + `routes/api.php` (110 routes).
Kode server menang atas docs bila konflik — verifikasi ini menemukan kontrak akurat, tidak perlu koreksi backend.

Base `{APP_URL}/api/v1`. Auth Sanctum Bearer, token di secure storage.
Login 10/menit, authed 120/menit. Format: paginator apa adanya,
detail `{data}`, aksi `{message,data}`, 422 `{message,errors}`.
Branch: tanpa assignment = DENIED. `branch_id` manipulasi → 403,
lintas cabang → 404. Health publik: `{status ok|degraded|error, checks{database,cache,queue,failed_jobs?}, app, time}`.

Perbaikan Flutter vs asumsi awal (ditemukan saat verifikasi):
- Payment WAJIB `payment_date` (required|date) + `amount` + `payment_method_id` + `idempotency_key?`
  (juga diterima via header `Idempotency-Key`). Server: lockForUpdate, guard sisa, 422 bila lunas/overpay.
- Stock-adjust WAJIB `{quantity, type: add|subtract|set, notes?}` (bukan `qty`).
- Vehicle store WAJIB `customer_id, vehicle_type_id, vehicle_brand_id, fuel_type_id, number_plate`
  (+ `chassis_number?, engine_number?, odometer?`). Search: number_plate/engine/chassis.
- Jobcard store WAJIB `customer_id, vehicle_id, title, service_date` (done_status system-managed).
- POS checkout WAJIB `session_id, items[{product_id, quantity, ...}], amount_paid, payment_method_id`
  (+ `idempotency_key?`). Diskon butuh role admin/manager.
- Photos ADA: `POST /vehicles/{id}/images`, `POST /services/{id}/images`
  (multipart `image` jpeg|png|webp ≤5MB + `caption?`/`type?` → `data.url` absolut),
  `DELETE .../images/{imageId}` (scope parent, lintas cabang 404).
- Device tokens ADA (push-ready): `POST /device-tokens {token, platform?}` idempoten,
  `DELETE /device-tokens {token}`. Tabel `fleet_notification_tokens`.

Idempotency: payments & POS checkout kirim `idempotency_key` uuid ≤64 (server dedup unik).
Task start/pause/finish idempoten (start saat in_progress → record sama; pause/finish no-op aman).
Approval estimate idempoten untuk retry.
