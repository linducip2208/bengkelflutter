import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Sanctum WAJIB secure storage. Jangan SharedPreferences untuk secret.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? s})
    : _s = s ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _k = 'sanctum_token';
  Future<String?> read() => _s.read(key: _k);
  Future<void> save(String v) => _s.write(key: _k, value: v);
  Future<void> clear() => _s.delete(key: _k);
}
