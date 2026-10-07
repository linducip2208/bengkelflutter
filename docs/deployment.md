# Deployment & setup

## SDK

Flutter 3.41.6, Dart 3.11.4, Android SDK 36.1.0 + build-tools, JDK 21
(bundel Android Studio). iOS butuh macOS + Xcode (tidak tersedia di sini).

## Env

`--dart-define=APP_ENV=dev|staging|prod`
`--dart-define=API_BASE_URL=https://host/api/v1`
Lihat `.env.example`. Jangan commit `.env`, keystore, `key.properties`,
`google-services.json`, `GoogleService-Info.plist`.

## Release Android

1. `cp android/key.properties.example android/key.properties` + isi
2. `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
3. `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`
4. Production endpoint wajib HTTPS publik (bukan localhost).

## Troubleshooting

- 422 payment tanpa payment_date → tambah `payment_date YYYY-MM-DD`
- stock 422 → `{quantity, type}`; vehicle/jobcard 422 → cek field WAJIB di kontrak
- 403 → role/cabang; 404 → lintas cabang (jangan retry branch lain); 429 → backoff
- Desugaring error → `isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs` (sudah)
- iOS build di Windows → NOT EXECUTED (butuh macOS); audit source-level Done
