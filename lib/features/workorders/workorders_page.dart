import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Work order = Service/jobcard lifecycle timeline:
/// Check-in → Inspection → Findings → Estimate → Approval → Work → QC → Invoice → Payment → Release.
/// Semua stage dari state server aktual, tidak difabrikasi.
class WorkOrdersPage extends ConsumerWidget {
  const WorkOrdersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Work Orders')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.jobcards, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada work order');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final j = items[i];
            return AppCard(
              child: ListTile(
                title: Text(
                  '${j['job_no'] ?? 'JOB-${j['id']}'} • ${j['title'] ?? ''}',
                ),
                subtitle: Text(
                  'done_status ${j['done_status'] ?? '-'} • workflow ${j['workflow_status'] ?? '-'}',
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class WorkOrderDetail extends ConsumerWidget {
  const WorkOrderDetail({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text('Work Order $id')),
    body: FutureBuilder(
      future: ref.watch(genericRemoteProvider).detail('/jobcards/$id'),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final d = (s.data ?? {}) as Map;
        final stages = [
          ('Check-in', d['jobcardDetail'] != null || d['created_at'] != null),
          ('Inspection', d['serviceObservationPoints'] != null),
          ('Estimate', d['estimates'] != null),
          (
            'Work',
            (d['workflow_status'] ?? 0) is int &&
                (d['workflow_status'] as int) >= 5,
          ),
          (
            'QC',
            (d['workflow_status'] ?? 0) is int &&
                (d['workflow_status'] as int) >= 8,
          ),
          ('Invoice', d['invoice'] != null),
          ('Paid', d['paid_at'] != null),
        ];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (label, done) in stages)
              ListTile(
                leading: Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  color: done ? Colors.green : Colors.grey,
                ),
                title: Text(label),
              ),
            const SizedBox(height: 8),
            Text('$d', style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    ),
  );
}

class BookingDetail extends ConsumerWidget {
  const BookingDetail({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text('Booking $id')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .detail(R.bookingConvert(id).replaceAll('/convert', '')),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${s.data}'),
        );
      },
    ),
  );
}
