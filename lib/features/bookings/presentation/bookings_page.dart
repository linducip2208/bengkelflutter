import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Bookings')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.bookings, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada booking');
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final b = items[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(
                          text: '${b['status'] ?? '-'}',
                          color: statusColor('${b['status'] ?? ''}'),
                        ),
                      ],
                    ),
                    Text('${b['customer'] ?? ''} • ${b['vehicle'] ?? ''}'),
                    Text(
                      '${b['date'] ?? b['scheduled_at'] ?? ''} • ${b['branch'] ?? ''}',
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => ref
                              .read(apiProvider)
                              .dio
                              .post(R.bookingConvert((b['id'] as num).toInt())),
                          child: const Text('Check-in / Convert'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
