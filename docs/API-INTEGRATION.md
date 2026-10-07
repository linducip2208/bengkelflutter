# API Integration — Bengkel Paten

Base `{APP_URL}/api/v1`. Auth Sanctum Bearer, token di secure storage.
Login 10/menit, authed 120/menit. Format: paginator apa adanya,
detail `{data}`, aksi `{message,data}`, 422 `{message,errors}`.
Branch: tanpa assignment = DENIED. `branch_id` manipulasi → 403,
lintas cabang → 404. Idempotency: payments & POS checkout kirim
`idempotency_key` uuid ≤64. Upload multipart belum ada di v1.
FCM push roadmap (belum ada endpoint daftar token).
