# Flutter ↔ Backend Contract — Bengkel (verified 2026-10-07)

Base `{APP_URL}/api/v1`. JSON saja. Auth: Sanctum Bearer
(`POST /login {email,password} → {user{roles,permissions},token}`;
`GET /me`; `POST /logout` cabut token ini). Throttle login 10/mnt, authed 120/mnt.
Header `Authorization: Bearer`, `Accept/Content-Type: application/json`.
Token exp `SANCTUM_TOKEN_EXPIRATION` (default 57600 mnt). 401 → login ulang.

## Konvensi

- Koleksi: paginator Laravel apa adanya (`current_page,data,per_page,total,last_page,...`).
- Detail: `{data:{...}}`. Aksi: `{message,data}` (200/201/422/401/403/404).
- Validasi 422: `{message, errors:{field:[...]}}`. Bisnis 422: `{message}`.
- Lintas cabang: 404 (anti enumerasi). Manipulasi branch_id: 403.
- Filter: `?per_page (20), ?page, ?status, ?service_id, ?customer_id, ?date_from, ?date_to`;
  search: customers/vehicles(number_plate,engine,chassis)/products(name,code)/technicians(name).
- Idempotency: payments + POS checkout `idempotency_key ≤64` (unik DB); task start/pause/finish
  + approval idempoten server-side. Header fallback `Idempotency-Key` (payments).
- Timezone Asia/Jakarta; tanggal `YYYY-MM-DD`, datetime ISO-8601.

## Endpoints (110, prefix /api/v1)

| Method | Path | Auth | Validasi inti | Sukses | Error khusus |
|---|---|---|---|---|---|
| POST | /login | — (10/mnt) | email, password | 200 {user,token} | 401 Invalid credentials (termasuk nonaktif) |
| POST | /logout | Sanctum | — | 200 | 401 |
| GET | /me | Sanctum | — | 200 user | 401 |
| GET | /health | — | — | 200 {status:ok,degraded, checks, app, time} / 503 | 503 DB down |
| GET | /dashboard/stats | S | — | 200 agregat | 401 |
| GET | /master-data | S | — | 200 referensi | 401 |
| GET | /branches | S | — | 200 {data:[...akses]} / [] bila DENIED | 401 |
| GET | /notifications | S | per_page | paginator milik sendiri | 401 |
| CRUD | /customers | S | name W, phone W unik, email unik | 201 store | 422 duplikat |
| CRUD | /vehicles | S | customer_id, vehicle_type_id, vehicle_brand_id, fuel_type_id, number_plate W (+chassis/engine/odometer) | 201 | 422 |
| POST/DELETE | /vehicles/{id}/images, /images/{imageId} | S+mekanik / tulis SA | image jpeg/png/webp ≤5MB + caption? | 201 {data.url absolut} | 422/404 |
| GET,POST complete | /services, /services/{id}/complete | S / admin,mgr,SA | store butuh customer/vehicle/title/service_date | 201 / complete idempoten | 422 |
| POST/DELETE | /services/{id}/images | S+mekanik | image + type? + caption? | 201 | 422/404 |
| CRUD+convert | /bookings | S / tulis admin,mgr,SA | store {name,phone,booking_at W}; update {status in pending,confirmed,in_progress,done,cancelled} | convert 201 {service_id,job_no} | 422 status ilegal |
| CRUD+complete | /jobcards | S / tulis admin,mgr,SA | {customer_id,vehicle_id,title,service_date W}; done_status system | 201 | 422 |
| GET+approve/reject/decide/convert | /estimates | S / tulis admin,mgr,SA; convert admin,mgr | approve {method?,reason?}; decide {decisions[{group_id,decision}],method?} | convert 201 invoice | 422 state ilegal |
| GET+qc | /work-packages | S / qc admin,mgr,SA | {result passed/failed W, notes?, task_id?} (gagal wajib notes) | 201 | 422/409 paket belum selesai |
| GET+start/pause/finish | /work-tasks | S / +mekanik | — | idempoten (start in_progress→sama) | 422/409 ilegal |
| GET | /findings, /services/{id}/inspections | S | service_id?, status? | {checklist,findings} | 404 |
| GET | /technicians | S | search? (mekanik aktif) | paginator | 401 |
| GET/POST/PUT/DELETE +pay +pdf | /invoices | S baca; tulis admin,mgr; hapus admin; pay admin,mgr,kasir | pay {amount, payment_method_id, payment_date W, idempotency_key?} | pay 201 (dedup key) | 422 lunas/overpay |
| CRUD+stock-adjust | /products | S baca; tulis inventory; hapus admin; adjust mgr,inventory | adjust {quantity, type add/subtract/set W} | quantity_after | 422 stok kurang |
| CRUD+receive | /purchases | S baca; tulis mgr; hapus admin; receive +inventory | store {supplier_id, purchase_date, items[{product_id,quantity≥0.01,unit_price}] W} | 201 | 422 bukan draft |
| PO receive/transition | /purchase-orders/{id}/{receive,submit,approve,close} | login+role/cabang | receipt_items? | {id,status} | 403/404/422 |
| CRUD | /sales | baca +kasir,inventory; tulis +kasir; hapus admin | — | 201 | 403 |
| CRUD | /suppliers | baca +inventory; tulis +inventory; hapus admin | {name W} | 201 | 422 |
| CRUD | /incomes,/expenses | admin,mgr | — | 201 | 403 |
| open/close/checkout | /pos/* | admin,mgr,kasir | open {opening_balance,branch_id W}; checkout {session_id, items[{product_id,quantity...}], amount_paid, payment_method_id W} | 201 {invoice,change} | 403 diskon/422 sesi |
| mark-paid | /commissions/{id}/mark-paid | admin,mgr | — | 200 | 403 |
| CRUD | /warranty-claims | baca S; tulis SA; update mgr; hapus admin | store {invoice_item_id, claim_date, complaint W}; update {status submitted/approved/rejected/resolved W} | 201 | 422 |
| GET | /reports/{service,sales,stock,financial} | S branch-scoped | — | 200 agregat server | 401 |
| POST/DELETE | /device-tokens | S (milik sendiri) | {token W, platform android/ios/web?} idempoten | 201 | 422 |

Role: super_admin/admin = semua cabang; selainnya wajib assignment cabang.
Uang dihitung server; stok lock baris (negatif ditolak); approval/task/invoice
server-wins atas offline.
