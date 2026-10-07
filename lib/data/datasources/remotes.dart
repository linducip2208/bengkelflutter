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
