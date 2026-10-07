import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Suppliers — validasi server: store {name WAJIB, email?, phone?, address?,
/// contact_person?, tax_id?, notes?}. Tulis: inventory(+admin); hapus: admin.
class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Suppliers')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.suppliers, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada supplier');
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return AppCard(
                child: ListTile(
                  title: Text('${v['name'] ?? '-'}'),
                  subtitle: Text(
                    '${v['phone'] ?? ''} • ${v['contact_person'] ?? ''}',
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => appBottomSheet(context, const _SupplierForm()),
      child: const Icon(Icons.add),
    ),
  );
}

class _SupplierForm extends ConsumerStatefulWidget {
  const _SupplierForm();
  @override
  ConsumerState<_SupplierForm> createState() => _SF();
}

class _SF extends ConsumerState<_SupplierForm> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final contact = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppInput(controller: name, label: 'Nama (wajib)'),
      const SizedBox(height: 8),
      AppInput(
        controller: phone,
        label: 'Telepon',
        keyboard: TextInputType.phone,
      ),
      const SizedBox(height: 8),
      AppInput(controller: contact, label: 'Contact person'),
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
                  R.suppliers,
                  data: {
                    'name': name.text,
                    if (phone.text.isNotEmpty) 'phone': phone.text,
                    if (contact.text.isNotEmpty) 'contact_person': contact.text,
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
