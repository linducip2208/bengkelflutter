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
              // Server fields: number_plate, chassis_number, engine_number,
              // odometer, model_name, model_year (+ customer, vehicleType...).
              return AppCard(
                child: ListTile(
                  title: Text('${v['number_plate'] ?? '-'}'),
                  subtitle: Text(
                    'Rangka ${v['chassis_number'] ?? '-'} • Mesin ${v['engine_number'] ?? '-'} • odo ${v['odometer'] ?? '-'}',
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
  final customerId = TextEditingController();
  final typeId = TextEditingController();
  final brandId = TextEditingController();
  final fuelId = TextEditingController();
  final plate = TextEditingController();
  final chassis = TextEditingController();
  final engine = TextEditingController();
  final odo = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Server WAJIB: customer_id, vehicle_type_id, vehicle_brand_id,
      // fuel_type_id, number_plate. Lihat ApiVehicleController@store.
      AppInput(
        controller: customerId,
        label: 'customer_id',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 8),
      AppInput(
        controller: typeId,
        label: 'vehicle_type_id',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 8),
      AppInput(
        controller: brandId,
        label: 'vehicle_brand_id',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 8),
      AppInput(
        controller: fuelId,
        label: 'fuel_type_id',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 8),
      AppInput(controller: plate, label: 'number_plate'),
      const SizedBox(height: 8),
      AppInput(controller: chassis, label: 'chassis_number (opsional)'),
      const SizedBox(height: 8),
      AppInput(controller: engine, label: 'engine_number (opsional)'),
      const SizedBox(height: 8),
      AppInput(
        controller: odo,
        label: 'odometer',
        keyboard: TextInputType.number,
      ),
      if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 12),
      AppButton(
        label: 'Simpan',
        onPressed: () async {
          try {
            await ref
                .read(apiProvider)
                .dio
                .post(
                  R.vehicles,
                  data: {
                    'customer_id': int.parse(customerId.text),
                    'vehicle_type_id': int.parse(typeId.text),
                    'vehicle_brand_id': int.parse(brandId.text),
                    'fuel_type_id': int.parse(fuelId.text),
                    'number_plate': plate.text,
                    if (chassis.text.isNotEmpty) 'chassis_number': chassis.text,
                    if (engine.text.isNotEmpty) 'engine_number': engine.text,
                    if (odo.text.isNotEmpty) 'odometer': int.parse(odo.text),
                  },
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            setState(() => err = '$e');
          }
        },
      ),
    ],
  );
}
