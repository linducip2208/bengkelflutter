# Architecture — bengkelflutter

Clean-ish: `app/` (root+providers) → `core/` (network/storage/error) →
`domain/entities` → `data/datasources` → `features/*/presentation`.
Business logic di repository/VM (Riverpod), bukan di Widget.

Backend Laravel single source of truth. Mirror `routes/api.php` di
`lib/core/network/api_paths.dart`. Konflik: kode menang.
