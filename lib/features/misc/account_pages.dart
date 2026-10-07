import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/branch_net.dart';
import '../../../app/providers.dart';
import '../../../data/datasources/remotes.dart';
import '../../../shared/widgets/components.dart';

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(branchIdProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      body: FutureBuilder(
        future: BranchRemote(ref.watch(apiProvider)).list(),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final items = s.data ?? [];
          if (items.isEmpty) {
            return const AppEmptyState(
              title: 'Tidak ada cabang akses',
              subtitle:
                  'Akun tanpa assignment = DENIED (data nol). Hubungi admin.',
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final b = items[i];
              final sel = selected == b.id;
              return AppCard(
                child: ListTile(
                  title: Text(b.name),
                  subtitle: Text(b.code),
                  trailing: sel
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () => ref.read(branchIdProvider.notifier).select(b.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = ref.watch(authProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u?.name ?? '-'),
                Text(u?.email ?? ''),
                Text('Roles: ${(u?.roles ?? []).join(', ')}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              await ref.read(branchIdProvider.notifier).select(null);
            },
            child: const Text('Logout (bersihkan kredensial + cabang)'),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'API via --dart-define API_BASE_URL. ENV: dev/staging/prod via APP_ENV. Tidak ada secret di source.',
      ),
    ),
  );
}

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Reports')),
    body: FutureBuilder(
      future: ref.watch(genericRemoteProvider).detail(R.reportService),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${s.data}', style: const TextStyle(fontSize: 12)),
        );
      },
    ),
  );
}

class PosPage extends ConsumerWidget {
  const PosPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('POS')),
    body: const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Buka sesi (opening_balance + branch_id) → checkout (session_id, items, amount_paid) → tutup sesi. Harga otoritatif server.',
      ),
    ),
  );
}
