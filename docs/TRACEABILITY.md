# Traceability — SCREEN → STATE → REPOSITORY → API → LARAVEL SERVICE → DATABASE → TEST

Sumber: `D:\project laravel\bengkel\docs\FLUTTER-API-CONTRACT.md` + `routes/api.php`.
Aturan: kode server menang atas docs. Tidak ada endpoint inventarisasi.

| # | SCREEN | STATE (Riverpod) | REPOSITORY (Dart) | API (v1) | LARAVEL SERVICE | DATABASE |
|---|---|---|---|---|---|---|
| 1 | LoginPage | AuthVM login/me/logout | AuthRemote | POST /login, GET /me, POST /logout | AuthController + Sanctum PAT | users, personal_access_tokens |
| 2 | DashboardPage | Future detail | GenericRemote.detail | GET /dashboard/stats | ApiDashboardController@stats | services, invoices, products (aggregate) |
| 3 | CustomersPage/Form | load()+debounce search | GenericRemote.list/detail + POST | GET/POST /customers, GET /customers/{id} | ApiCustomerController (IdentityNormalizer) | customers |
| 4 | VehiclesPage/Form | Future list | GenericRemote + POST | GET/POST /vehicles | ApiVehicleController@store validasi customer_id, vehicle_type_id, vehicle_brand_id, fuel_type_id, number_plate | vehicles |
| 5 | BookingsPage | Future list | GenericRemote + POST convert | GET /bookings, POST /bookings/{id}/convert | BookingService::convertToService | bookings → services |
| 6 | CheckinSheet | form confirm | POST | POST /jobcards {customer_id, vehicle_id, title, service_date} | ApiJobcardController@store (done_status system) | services |
| 7 | InspectionPage | Future detail | GenericRemote.detail | GET /services/{id}/inspections | ApiWorkshopController@inspections | service_observation_points, service_findings |
| 8 | FindingsPage | Future list | GenericRemote.list | GET /findings | ApiWorkshopController@findings | service_findings |
| 9 | EstimatesPage/Detail | Future | GenericRemote + POST | GET /estimates, POST .../approve {method?,reason?}, /reject {reason?}, /decide {decisions[{group_id,decision}],method?}, /convert | EstimateService::approve/reject/convertToInvoice, WorkshopFlowService::submitGroupDecisions | service_estimates, service_estimate_groups/items |
| 10 | TasksPage | Future + role guard | POST | POST /work-tasks/{id}/{start\|pause\|finish} | WorkshopFlowService::startTask (idempoten in_progress) /pauseTask/finishTask (→qc_pending), lockForUpdate + time entries | service_work_tasks, service_work_time_entries |
| 11 | InventoryPage | Future + role guard | POST | POST /products/{id}/stock-adjust {quantity, type:add\|subtract\|set, notes?} | StockService::increment/decrement/set (locked, 422 bila kurang) | products, stock_records/histories |
| 12 | QcSheet | form + guard | POST | POST /work-packages/{id}/qc {result:passed\|failed, notes?, task_id?} | WorkshopFlowService::submitQc (gagal wajib notes) | service_work_qc_checks |
| 13 | InvoicesPage/PayDialog | dialog form | POST | POST /invoices/{id}/payments {amount, payment_method_id, payment_date, reference_number?, notes?, idempotency_key?} | PaymentService::process (lockForUpdate, sisa guard, idempoten, jurnal) | payment_records (unique idempotency_key), invoices, incomes |
| 14 | POS (remote siap) | — | PosRemote | POST /pos/open {opening_balance,branch_id}, /pos/close {closing_balance}, /pos/checkout {session_id, items[{product_id,quantity,...}], amount_paid, payment_method_id, idempotency_key?} | PosService::checkout (harga server-side, branch check, discount role) | pos_sessions, invoices, sales |
| 15 | Photos | picker+permission | PhotoRemote.upload/delete | POST /vehicles/{id}/images, POST /services/{id}/images (multipart image jpeg\|png\|webp ≤5MB + caption/type?), DELETE .../images/{imageId} | ApiVehicleController@uploadImage, ApiServiceController@uploadImage (nama acak, public disk) | vehicle_images, service_images |
| 16 | NotificationsPage | Future + unread | GenericRemote.list | GET /notifications (milik sendiri) | ApiWorkshopController@notifications | notifications |
| 17 | Device tokens | — | DeviceTokenRemote | POST /device-tokens {token, platform?} idempoten, DELETE /device-tokens {token} | ApiWorkshopController@register/unregister | fleet_notification_tokens |
| 18 | Health | — | HealthRemote | GET /health publik {status, checks{database,cache,queue,failed_jobs?}, app, time} | ApiWorkshopController@health | DB/cache/failed_jobs checks |

## Server-wins (tidak boleh dioverride offline)

Financial (estimate convert, invoice, payment, POS), inventory (stock-adjust,
purchase receive), approval (approve/reject/decide), work-task/QC:
Flutter TIDAK pernah menulis total/harga/status ke DB lokal sebagai kebenaran.
Pola wajib: enqueue dengan idempotency_key → saat online POST → GET detail
ulang untuk rekonsiliasi → tampilkan hasil server. Lihat `docs/OFFLINE-SYNC.md`.
