import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/roles.dart';
import '../../../shared/widgets/components.dart';

/// MY TASKS mekanik: vehicle, job, priority, parts, timer, status.
/// START PAUSE RESUME FINISH. Server otoritatif. Cegah double timer aktif.
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    final canDrive = Roles.canDriveTask(roles);
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: FutureBuilder(
        future: ref
            .watch(genericRemoteProvider)
            .list(R.workTasks, query: pagedQuery()),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final items = s.data?.items ?? [];
          if (items.isEmpty) {
            return const AppEmptyState(title: 'Tidak ada tugas');
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final t = items[i];
                final id = (t['id'] as num).toInt();
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge(
                            text: '${t['status'] ?? ''}',
                            color: statusColor('${t['status'] ?? ''}'),
                          ),
                          const SizedBox(width: 8),
                          Text('Prio ${t['priority'] ?? '-'}'),
                        ],
                      ),
                      Text(
                        '${t['vehicle'] ?? ''} • ${t['job'] ?? t['title'] ?? ''}',
                      ),
                      Text(
                        '${t['description'] ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (canDrive)
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => ref
                                  .read(apiProvider)
                                  .dio
                                  .post(R.taskStart(id)),
                              child: const Text('START'),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(apiProvider)
                                  .dio
                                  .post(R.taskPause(id)),
                              child: const Text('PAUSE'),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(apiProvider)
                                  .dio
                                  .post(R.taskFinish(id)),
                              child: const Text('FINISH'),
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
}
