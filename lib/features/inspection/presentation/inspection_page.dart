import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Inspection mobile-first: checklist besar, touch-friendly untuk bengkel.
class InspectionPage extends ConsumerWidget {
  const InspectionPage({super.key, required this.serviceId});
  final int serviceId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text('Inspection $serviceId')),
    body: FutureBuilder(
      future: ref.watch(genericRemoteProvider).detail(R.inspections(serviceId)),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [Text('${s.data}', style: const TextStyle(fontSize: 12))],
        );
      },
    ),
  );
}
