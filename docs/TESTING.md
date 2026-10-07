# Testing

`flutter test` untuk unit/widget/repo/api/model/db/sync/auth/workflow.
Mock API deterministik (mocktail) untuk 200/201/204/400/401/403/404/
409/422/429/500/timeout/offline. Jangan tergantung production API.
Offline: online→offline→online, queue survive, retry, no duplikat,
konflik visible. Workflow kritis: login→customer→vehicle→booking→
checkin→inspection→finding→estimate→approval→task→timer→parts→
QC→invoice→payment→pickup.
