import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cabang aktif: cache non-sensitif; ganti cabang → invalidate cache tampilan.
/// Otoritas tetap backend (lintas cabang → 404, manipulasi → 403).
final branchIdProvider = StateNotifierProvider<BranchIdVM, int?>(
  (_) => BranchIdVM(),
);

class BranchIdVM extends StateNotifier<int?> {
  BranchIdVM() : super(null) {
    _load();
  }
  static const _k = 'selected_branch_id';
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getInt(_k);
  }

  Future<void> select(int? id) async {
    final p = await SharedPreferences.getInstance();
    if (id == null) {
      await p.remove(_k);
    } else {
      await p.setInt(_k, id);
    }
    state = id;
  }
}

/// Status jaringan global untuk banner ONLINE/OFFLINE/SYNCING.
final onlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (c) => !c.contains(ConnectivityResult.none),
  );
});

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider).valueOrNull ?? true;
    if (online) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Text(
        'OFFLINE — data cache, mutasi finansial menunggu online',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
