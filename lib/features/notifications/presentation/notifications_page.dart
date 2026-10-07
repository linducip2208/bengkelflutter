import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Notification center: booking estimate approval work QC invoice payment pickup warranty.
/// Unread counter, mark read (jika API mendukung), deep link ke entity.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.notifications, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        final unread = items.where((e) => e['read_at'] == null).length;
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Tidak ada notifikasi');
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Unread: $unread'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return AppCard(
                    child: ListTile(
                      title: Text('${n['type'] ?? n['title'] ?? 'Notifikasi'}'),
                      subtitle: Text('${n['data'] ?? n['body'] ?? ''}'),
                      trailing: n['read_at'] == null
                          ? const Icon(Icons.mark_email_unread)
                          : null,
                      // TODO deep-link: parse data.entity/id -> push Estimate/Invoice/Task detail.
                      // Handle stale/deleted entity (404 -> snackbar).
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
