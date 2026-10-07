# Offline Sync

UI → Repository → Local DB (sqflite `bengkel_sync.db`) → Sync Queue → Laravel.
Queue kolom: id, operation, entity, entity_id, payload, created_at,
attempts, last_error, status (PENDING/SYNCING/SUCCESS/FAILED/CONFLICT).
Retry exponential backoff 2^attempts (max 60s). Idempotency key per
transaksi. Konflik: server menang untuk estimate/approval/task/
inventory/invoice/payment; catat + notifikasi, jangan overwrite diam-diam.
Read cacheable via `cache_kv`. Jangan buang offline changes diam-diam.
