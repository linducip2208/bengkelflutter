import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/roles.dart';
import '../../../shared/widgets/components.dart';

/// Warranty — store WAJIB {invoice_item_id, claim_date, complaint}.
/// Update: {status: submitted|approved|rejected|resolved, resolution?}
/// via WarrantyClaimService (manager update, admin delete).
class WarrantyPage extends ConsumerWidget {
  const WarrantyPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Warranty')),
      body: FutureBuilder(
        future: ref
            .watch(genericRemoteProvider)
            .list(R.warrantyClaims, query: pagedQuery()),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final items = s.data?.items ?? [];
          if (items.isEmpty) {
            return const AppEmptyState(title: 'Belum ada klaim garansi');
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return AppCard(
                child: ListTile(
                  title: Text('Claim #${v['id']} • ${v['status'] ?? ''}'),
                  subtitle: Text('${v['complaint'] ?? ''}'),
                  trailing: StatusBadge(
                    text: '${v['status'] ?? ''}',
                    color: statusColor('${v['status'] ?? ''}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          Roles.unrestricted(roles) || roles.contains(Roles.advisor)
          ? FloatingActionButton(
              onPressed: () => appBottomSheet(context, const _WarrantyForm()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _WarrantyForm extends ConsumerStatefulWidget {
  const _WarrantyForm();
  @override
  ConsumerState<_WarrantyForm> createState() => _WF();
}

class _WF extends ConsumerState<_WarrantyForm> {
  final itemId = TextEditingController();
  final date = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  final complaint = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppInput(
        controller: itemId,
        label: 'invoice_item_id',
        keyboard: TextInputType.number,
      ),
      const SizedBox(height: 8),
      AppInput(controller: date, label: 'claim_date YYYY-MM-DD'),
      const SizedBox(height: 8),
      AppInput(controller: complaint, label: 'Keluhan'),
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
                  R.warrantyClaims,
                  data: {
                    'invoice_item_id': int.parse(itemId.text),
                    'claim_date': date.text,
                    'complaint': complaint.text,
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
