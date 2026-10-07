import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Findings by severity: new resolved approved rejected additional work.
class FindingsPage extends ConsumerWidget {
  const FindingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Findings')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.findings, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Tidak ada finding');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final f = items[i];
            return AppCard(
              child: ListTile(
                title: Text(
                  '${f['title'] ?? 'Finding'} • ${f['severity'] ?? ''}',
                ),
                subtitle: Text('${f['note'] ?? ''} • ${f['status'] ?? ''}'),
                trailing: StatusBadge(
                  text: '${f['severity'] ?? f['status'] ?? ''}',
                  color: statusColor('${f['severity'] ?? ''}'),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
