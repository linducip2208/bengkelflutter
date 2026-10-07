import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});
  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesState();
}

class _VehiclesState extends ConsumerState<VehiclesPage> {
  int reload = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Vehicles')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.vehicles, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(
            message: '${s.error}',
            onRetry: () => setState(() => reload++),
          );
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada kendaraan');
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return AppCard(
                child: ListTile(
                  title: Text('${v['plate_number'] ?? v['plate'] ?? '-'}'),
                  subtitle: Text(
                    'VIN ${v['vin'] ?? '-'} • ${v['brand'] ?? ''} ${v['model'] ?? ''} ${v['year'] ?? ''} • odo ${v['mileage'] ?? v['odometer'] ?? '-'}',
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => appBottomSheet(context, const _VehicleForm()),
      child: const Icon(Icons.add),
    ),
  );
}

class _VehicleForm extends ConsumerStatefulWidget {
  const _VehicleForm();
  @override
  ConsumerState<_VehicleForm> createState() => _VF();
}

class _VF extends ConsumerState<_VehicleForm> {
  final plate = TextEditingController();
  final vin = TextEditingController();
  final mileage = TextEditingController();
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppInput(controller: plate, label: 'Plat nomor'),
      const SizedBox(height: 8),
      AppInput(controller: vin, label: 'VIN / rangka'),
      const SizedBox(height: 8),
      AppInput(
        controller: mileage,
        label: 'Mileage',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 12),
      AppButton(
        label: 'Simpan',
        onPressed: () async {
          await ref
              .read(apiProvider)
              .dio
              .post(
                R.vehicles,
                data: {
                  'plate_number': plate.text,
                  'vin': vin.text,
                  'mileage': mileage.text,
                },
              );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    ],
  );
}
