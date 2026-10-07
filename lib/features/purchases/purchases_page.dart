import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/widgets/components.dart';

/// Purchases — store WAJIB {supplier_id, purchase_date, items[{product_id,
/// quantity≥0.01, unit_price}]}. Update/hapus hanya status draft (422 bila
/// bukan draft). Receive via POST /purchases/{id}/receive (+inventory).
/// PO: receive/submit/approve/close dengan guard role+cabang server-side.
class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Purchases')),
    body: FutureBuilder(
      future: ref
          .watch(genericRemoteProvider)
          .list(R.purchases, query: pagedQuery()),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(message: '${s.error}', onRetry: () {});
        }
        final items = s.data?.items ?? [];
        if (items.isEmpty) {
          return const AppEmptyState(title: 'Belum ada purchase');
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              final id = (v['id'] as num).toInt();
              final draft = '${v['status'] ?? ''}' == 'draft';
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(
                          text: '${v['status'] ?? '-'}',
                          color: statusColor('${v['status'] ?? ''}'),
                        ),
                      ],
                    ),
                    Text('PO-$id • ${v['purchase_date'] ?? ''}'),
                    if (draft)
                      TextButton(
                        onPressed: () => ref
                            .read(apiProvider)
                            .dio
                            .post(R.purchaseReceive(id)),
                        child: const Text('Receive'),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => appBottomSheet(context, const _PurchaseForm()),
      child: const Icon(Icons.add),
    ),
  );
}

class _PurchaseForm extends ConsumerStatefulWidget {
  const _PurchaseForm();
  @override
  ConsumerState<_PurchaseForm> createState() => _PF();
}

class _PF extends ConsumerState<_PurchaseForm> {
  final supplierId = TextEditingController();
  final date = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  final productId = TextEditingController();
  final qty = TextEditingController(text: '1');
  final price = TextEditingController(text: '0');
  String? err;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          controller: supplierId,
          label: 'supplier_id',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(controller: date, label: 'purchase_date YYYY-MM-DD'),
        const SizedBox(height: 8),
        AppInput(
          controller: productId,
          label: 'product_id item 1',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(
          controller: qty,
          label: 'quantity ≥0.01',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(
          controller: price,
          label: 'unit_price',
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
                    R.purchases,
                    data: {
                      'supplier_id': int.parse(supplierId.text),
                      'purchase_date': date.text,
                      'items': [
                        {
                          'product_id': int.parse(productId.text),
                          'quantity': num.parse(qty.text),
                          'unit_price': num.parse(price.text),
                        },
                      ],
                    },
                  );
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              setState(() => err = '$e');
            }
          },
        ),
      ],
    ),
  );
}
