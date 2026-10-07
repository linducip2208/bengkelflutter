import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache baca (customers/vehicles/products/master) + last-synced.
/// Tidak untuk secret. Invalidate saat ganti cabang/user.
class ReadCache {
  static String _k(String entity) => 'cache_$entity';
  static String _t(String entity) => 'cache_${entity}_at';

  static Future<void> put(String entity, Object json) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k(entity), jsonEncode(json));
    await p.setString(_t(entity), DateTime.now().toIso8601String());
  }

  static Future<String?> lastSynced(String entity) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_t(entity));
  }

  static Future<void> invalidateAll() async {
    final p = await SharedPreferences.getInstance();
    for (final e in ['customers', 'vehicles', 'products', 'master']) {
      await p.remove(_k(e));
      await p.remove(_t(e));
    }
  }
}

/// Draft recovery untuk workflow panjang (inspeksi/finding/estimate/task).
/// Cegah hilang saat back/background/restart. Bukan untuk data sensitif.
class DraftStore {
  static String _k(String form) => 'draft_$form';

  static Future<void> save(String form, Map<String, dynamic> v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k(form), jsonEncode(v));
  }

  static Future<Map<String, dynamic>?> load(String form) async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_k(form));
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String form) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_k(form));
  }
}
