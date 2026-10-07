import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';
import '../../../domain/entities/roles.dart';

/// Estimate list + detail + approve/reject/decide/convert.
/// Status: DRAFT SENT WAITING APPROVAL APPROVED PARTIALLY APPROVED REJECTED EXPIRED SUPERSEDED.
class EstimatesPage extends ConsumerWidget {
  const EstimatesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Estimates')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.estimates, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada estimasi');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final e = items[i];
            return AppCard(
              child: ListTile(
                title: Text('EST-${e['id']} • ${e['status'] ?? ''}'),
                subtitle: Text(
                  'Total ${e['grand_total'] ?? e['total'] ?? '-'}',
                ),
                trailing: StatusBadge(
                  text: '${e['status'] ?? ''}',
                  color: statusColor('${e['status'] ?? ''}'),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EstimateDetail(id: (e['id'] as num).toInt()),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class EstimateDetail extends ConsumerWidget {
  const EstimateDetail({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Estimate $id')),
      body: FutureBuilder(
        future: ref.watch(genericRemoteProvider).detail(R.estimate(id)),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final d = s.data ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatusBadge(
                text: '${d['status'] ?? ''}',
                color: statusColor('${d['status'] ?? ''}'),
              ),
              const SizedBox(height: 8),
              Text('$d', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              if (Roles.canApproveEstimate(roles))
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ref
                            .read(apiProvider)
                            .dio
                            .post(
                              R.estimateApprove(id),
                              data: {'method': 'manual'},
                            ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref
                            .read(apiProvider)
                            .dio
                            .post(R.estimateReject(id)),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              if (Roles.canConvertEstimate(roles))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppButton(
                    label: 'Convert → Invoice',
                    onPressed: () =>
                        ref.read(apiProvider).dio.post(R.estimateConvert(id)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
