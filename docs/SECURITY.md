# Security

- Token hanya `flutter_secure_storage`, hapus saat logout/401.
- Jangan log password/token/API key/payment secret.
- Logout: clear token + sensitive cache + queue user tersebut bila kebijakan.
- Jangan bocorkan data Branch A ke akun Branch B (invalidate cache per user).
- Validasi input sesuai Laravel, error 401/403/422/429/500 di-map terpusat.
- Deep link & URL divalidasi, entity stale/deleted ditangani aman.
