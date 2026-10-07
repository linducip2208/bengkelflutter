import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/roles.dart';
import '../../../shared/widgets/components.dart';

/// Parts: required/reserved/available/used. Mobile TIDAK mutasi stok langsung.
/// Mutasi hanya via API (stock-adjust dengan otoritas server).
class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: FutureBuilder(
        future: ref
            .watch(genericRemoteProvider)
            .list(R.products, query: pagedQuery()),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final items = s.data?.items ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return AppCard(
                child: ListTile(
                  title: Text('${p['name'] ?? '-'}'),
                  subtitle: Text(
                    'Stok ${p['stock'] ?? '-'} • ${p['sku'] ?? ''}',
                  ),
                  trailing: Roles.canManageStock(roles)
                      ? IconButton(
                          icon: const Icon(Icons.inventory),
                          // Server: StockService locked; body WAJIB
                          // {quantity, type: add|subtract|set, notes?}.
                          // Stok negatif ditolak 422; jangan optimistis.
                          onPressed: () => ref
                              .read(apiProvider)
                              .dio
                              .post(
                                R.productStockAdjust((p['id'] as num).toInt()),
                                data: {
                                  'quantity': 1,
                                  'type': 'add',
                                  'notes': 'adjust dari mobile',
                                },
                              ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
