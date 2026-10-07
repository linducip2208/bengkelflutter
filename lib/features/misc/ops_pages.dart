import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

class TechniciansPage extends ConsumerWidget {
  const TechniciansPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Technicians')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.technicians, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada teknisi');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final t = items[i];
            return AppCard(
              child: ListTile(
                title: Text('${t['name'] ?? '-'}'),
                subtitle: Text('${t['email'] ?? ''}'),
              ),
            );
          },
        );
      },
    ),
  );
}

class QcQueuePage extends ConsumerWidget {
  const QcQueuePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('QC Queue')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.workPackages, query: pagedQuery(status: 'completed')),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Tidak ada menunggu QC');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => AppCard(child: Text('PKG-${items[i]['id']}')),
        );
      },
    ),
  );
}

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const Scaffold(
    body: Center(child: Text('Pembayaran via Invoice → Bayar (idempoten).')),
  );
}
