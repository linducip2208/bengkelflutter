import '../../core/network/api_client.dart';
import '../../core/network/api_paths.dart';
import '../../core/network/page.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/entities/user_branch.dart';

/// Data layer: Auth (login/me/logout). Token di secure storage.
class AuthRemote {
  AuthRemote(this._api, this._tokens);
  final ApiClient _api;
  final TokenStorage _tokens;

  Future<(UserEntity, String)> login(String email, String password) async {
    final r = await _api.post(
      ApiPaths.login,
      data: {'email': email, 'password': password},
    );
    final m = r.data as Map<String, dynamic>;
    final token = m['token'] as String;
    final user = UserEntity.fromJson(m['user'] as Map<String, dynamic>);
    await _tokens.save(token);
    return (user, token);
  }

  Future<UserEntity> me() async {
    final r = await _api.get(ApiPaths.me);
    final m = r.data as Map<String, dynamic>;
    return UserEntity.fromJson(
      m['data'] is Map ? m['data'] as Map<String, dynamic> : m,
    );
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiPaths.logout);
    } finally {
      await _tokens.clear();
    }
  }
}

class BranchRemote {
  BranchRemote(this._api);
  final ApiClient _api;

  Future<List<BranchEntity>> list() async {
    final r = await _api.get(ApiPaths.branches);
    final d = r.data;
    final list = d is Map && d['data'] is List
        ? d['data'] as List
        : (d is List ? d : []);
    return list
        .map((e) => BranchEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class GenericRemote {
  GenericRemote(this._api);
  final ApiClient _api;

  Future<ApiPage<Map<String, dynamic>>> list(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final r = await _api.get(path, query: query);
    return ApiPage.fromJson(r.data as Map<String, dynamic>, (j) => j);
  }

  Future<Map<String, dynamic>> detail(String path) async {
    final r = await _api.get(path);
    return unwrapData(r.data as Map<String, dynamic>);
  }
}

/// Foto kendaraan & service — multipart `image` (jpeg|png|webp ≤5MB).
/// Upload: +mekanik. Hapus via parent scope (lintas cabang → 404).
/// Response: {message, data: {url absolut, ...}}.
class PhotoRemote {
  PhotoRemote(this._api);
  final ApiClient _api;

  Future<String> uploadVehicleImage(
    int vehicleId,
    String filePath, {
    String? caption,
  }) async {
    final r = await _api.upload(
      ApiPaths.vehicleImages(vehicleId),
      'image',
      filePath,
      fields: {'caption': ?caption},
    );
    final m = r.data as Map<String, dynamic>;
    return (m['data'] as Map<String, dynamic>)['url'] as String;
  }

  Future<void> deleteVehicleImage(int vehicleId, int imageId) =>
      _api.delete(ApiPaths.vehicleImage(vehicleId, imageId));

  Future<String> uploadServiceImage(
    int serviceId,
    String filePath, {
    String? type,
    String? caption,
  }) async {
    final r = await _api.upload(
      ApiPaths.serviceImages(serviceId),
      'image',
      filePath,
      fields: {'type': ?type, 'caption': ?caption},
    );
    final m = r.data as Map<String, dynamic>;
    return (m['data'] as Map<String, dynamic>)['url'] as String;
  }

  Future<void> deleteServiceImage(int serviceId, int imageId) =>
      _api.delete(ApiPaths.serviceImage(serviceId, imageId));
}

/// Push-ready: token FCM per device, idempoten per (user_id, token).
/// Tabel: fleet_notification_tokens. Hapus hanya milik sendiri.
class DeviceTokenRemote {
  DeviceTokenRemote(this._api);
  final ApiClient _api;

  Future<void> register(String token, {String? platform}) => _api.post(
    ApiPaths.deviceTokens,
    data: {'token': token, 'platform': ?platform},
  );

  Future<void> unregister(String token) =>
      _api.delete(ApiPaths.deviceTokens, data: {'token': token});
}

/// POS — server otoritatif penuh (PosService::checkout).
/// open: {opening_balance, branch_id}. close: {closing_balance}.
/// checkout WAJIB: {session_id, items[{product_id, quantity, ...}],
/// amount_paid, payment_method_id, idempotency_key?}.
/// Diskon/override harga butuh role admin/manager (403 bila tidak).
class PosRemote {
  PosRemote(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> open(double openingBalance, int branchId) async {
    final r = await _api.post(
      ApiPaths.posOpen,
      data: {'opening_balance': openingBalance, 'branch_id': branchId},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkout({
    required int sessionId,
    required List<Map<String, dynamic>> items,
    required num amountPaid,
    required int paymentMethodId,
    String? idempotencyKey,
  }) async {
    final r = await _api.post(
      ApiPaths.posCheckout,
      data: {
        'session_id': sessionId,
        'items': items,
        'amount_paid': amountPaid,
        'payment_method_id': paymentMethodId,
        'idempotency_key': ?idempotencyKey,
      },
    );
    return r.data as Map<String, dynamic>;
  }
}

/// Health publik: {status ok|degraded|error, checks{database,cache,queue,failed_jobs?}, app, time}.
class HealthRemote {
  HealthRemote(this._api);
  final ApiClient _api;
  Future<Map<String, dynamic>> check() async {
    final r = await _api.get(ApiPaths.health);
    return r.data as Map<String, dynamic>;
  }
}
