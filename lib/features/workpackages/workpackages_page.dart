import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';
import '../qc/presentation/qc_sheet.dart';

/// Work packages — baca semua staff; QC via submitQc.
/// Parts/labor/quantity/harga tampil apa adanya dari server (tidak dihitung lokal).
class WorkPackagesPage extends ConsumerWidget {
  const WorkPackagesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Work Packages')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.workPackages, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada work package');
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final v = items[i];
            final id = (v['id'] as num).toInt();
            return AppCard(
              child: ListTile(
                title: Text(
                  '${v['title'] ?? 'PKG-$id'} • ${v['status'] ?? ''}',
                ),
                subtitle: Text('Finding ${v['service_finding_id'] ?? '-'}'),
                trailing: StatusBadge(
                  text: '${v['status'] ?? ''}',
                  color: statusColor('${v['status'] ?? ''}'),
                ),
                onTap: () => appBottomSheet(context, QcSheet(packageId: id)),
              ),
            );
          },
        );
      },
    ),
  );
}
