import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Sync statuses: PENDING SYNCING SUCCESS FAILED CONFLICT.
enum SyncStatus { pending, syncing, success, failed, conflict }

/// Setiap mutasi tercatat: id, operation, entity, entity_id, payload,
/// created_at, attempts, last_error, status.
class SyncEngine {
  SyncEngine._(this._db);
  final Database _db;
  static const _uuid = Uuid();

  static Future<SyncEngine> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'bengkel_sync.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE queue(
            id TEXT PRIMARY KEY, operation TEXT NOT NULL, entity TEXT NOT NULL,
            entity_id TEXT, path TEXT NOT NULL, payload TEXT NOT NULL,
            idempotency_key TEXT NOT NULL, created_at TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0, last_error TEXT, status TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cache_kv(entity TEXT PRIMARY KEY, json TEXT NOT NULL, updated_at TEXT NOT NULL)
        ''');
      },
      onUpgrade: (db, old, _) async {
        if (old < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS cache_kv(entity TEXT PRIMARY KEY, json TEXT NOT NULL, updated_at TEXT NOT NULL)',
          );
        }
      },
    );
    return SyncEngine._(db);
  }

  /// Enqueue mutasi offline. Idempotency key auto uuid (≤64).
  Future<String> enqueue({
    required String operation,
    required String entity,
    String? entityId,
    required String path,
    required String payloadJson,
    String? idempotencyKey,
  }) async {
    final key = (idempotencyKey ?? _uuid.v4()).substring(
      0,
      (idempotencyKey ?? _uuid.v4()).length > 64
          ? 64
          : (idempotencyKey ?? _uuid.v4()).length,
    );
    final id = _uuid.v4();
    await _db.insert('queue', {
      'id': id,
      'operation': operation,
      'entity': entity,
      'entity_id': entityId,
      'path': path,
      'payload': payloadJson,
      'idempotency_key': key,
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
      'status': SyncStatus.pending.name.toUpperCase(),
    });
    return key;
  }

  Future<List<Map<String, Object?>>> pending() => _db.query(
    'queue',
    where: 'status IN (?,?)',
    whereArgs: ['PENDING', 'FAILED'],
    orderBy: 'created_at ASC',
  );

  Future<void> setStatus(
    String id,
    SyncStatus s, {
    String? error,
    int? attempts,
  }) async {
    await _db.update(
      'queue',
      {
        'status': s.name.toUpperCase(),
        'last_error': ?error,
        'attempts': ?attempts,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cache read (GET) agar read operations cacheable.
  Future<void> putCache(String entity, String json) => _db
      .insert('queue', {}, conflictAlgorithm: ConflictAlgorithm.ignore)
      .then(
        (_) => _db.insert('cache_kv', {
          'entity': entity,
          'json': json,
          'updated_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace),
      );

  Future<String?> readCache(String entity) async {
    final r = await _db.query(
      'cache_kv',
      where: 'entity = ?',
      whereArgs: [entity],
    );
    return r.isEmpty ? null : r.first['json'] as String?;
  }

  /// Retry dengan exponential backoff di caller: delay = 2^attempts detik (max 60).
  static Duration backoff(int attempts) {
    final s = 1 << (attempts > 5 ? 5 : attempts);
    return Duration(seconds: s > 60 ? 60 : s);
  }

  static Future<bool> get online async {
    final c = await Connectivity().checkConnectivity();
    return !c.contains(ConnectivityResult.none);
  }
}
