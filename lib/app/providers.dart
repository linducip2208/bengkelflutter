import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/network/api_client.dart';
import '../core/network/api_paths.dart';
import '../core/storage/token_storage.dart';
import '../data/datasources/remotes.dart';
import '../domain/entities/user_branch.dart';

final tokenStorageProvider = Provider((_) => TokenStorage());
final apiProvider = Provider(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);
final authRemoteProvider = Provider(
  (ref) => AuthRemote(ref.watch(apiProvider), ref.watch(tokenStorageProvider)),
);
final branchRemoteProvider = Provider(
  (ref) => BranchRemote(ref.watch(apiProvider)),
);
final genericRemoteProvider = Provider(
  (ref) => GenericRemote(ref.watch(apiProvider)),
);

final authProvider = StateNotifierProvider<AuthVM, AsyncValue<UserEntity?>>(
  (ref) => AuthVM(ref.watch(authRemoteProvider)),
);

class AuthVM extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthVM(this._remote) : super(const AsyncValue.data(null));
  final AuthRemote _remote;

  Future<void> login(String e, String p) async {
    state = const AsyncValue.loading();
    try {
      final (u, _) = await _remote.login(e, p);
      state = AsyncValue.data(u);
    } catch (err, st) {
      state = AsyncValue.error(err, st);
      rethrow;
    }
  }

  Future<void> loadMe() async {
    try {
      state = AsyncValue.data(await _remote.me());
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logout() async {
    await _remote.logout();
    state = const AsyncValue.data(null);
  }
}

const _uuid = Uuid();
String newIdempotencyKey() => _uuid.v4();

/// Query helper dengan debounce dilakukan di UI (SearchBar onChanged + Timer).
Map<String, dynamic> pagedQuery({
  int page = 1,
  int perPage = 20,
  String? search,
  String? status,
}) => {
  'page': page,
  'per_page': perPage,
  if (search != null && search.isNotEmpty) 'search': search,
  'status': ?status,
};

/// Re-export path favorit agar screen ringkas.
typedef R = ApiPaths;
