import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Approval inbox: estimasi waiting_approval. Partial approve via decide.
/// Final selalu dari server (refresh setelah mutasi).
class ApprovalsPage extends ConsumerWidget {
  const ApprovalsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Approvals')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.estimates, query: pagedQuery(status: 'waiting_approval')),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Tidak ada menunggu approval');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final e = items[i];
            return AppCard(
              child: ListTile(
                title: Text('EST-${e['id']}'),
                subtitle: Text(
                  'Total ${e['grand_total'] ?? e['total'] ?? '-'}',
                ),
                trailing: StatusBadge(
                  text: '${e['status'] ?? ''}',
                  color: statusColor('${e['status'] ?? ''}'),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
