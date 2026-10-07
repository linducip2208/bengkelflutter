import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/roles.dart';
import '../../../shared/widgets/components.dart';

/// Invoice: number customer vehicle items parts labor discount tax total paid remaining status.
/// PDF via GET /invoices/{id}/pdf. Payment idempotent di halaman payment.
class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: FutureBuilder(
        future: ref
            .watch(genericRemoteProvider)
            .list(R.invoices, query: pagedQuery()),
        builder: (_, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const AppLoadingList();
          }
          if (s.hasError) {
            return AppErrorState(message: '${s.error}', onRetry: () {});
          }
          final items = s.data?.items ?? [];
          if (items.isEmpty) {
            return const AppEmptyState(title: 'Belum ada invoice');
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INV-${v['number'] ?? v['id']} • ${v['payment_status'] ?? v['status'] ?? ''}',
                    ),
                    Text(
                      'Total ${v['total'] ?? '-'} • Paid ${v['paid_amount'] ?? v['paid'] ?? 0}',
                    ),
                    Row(
                      children: [
                        TextButton(onPressed: () {}, child: const Text('PDF')),
                        if (Roles.canPay(roles))
                          TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (_) => _PayDialog(
                                invoiceId: (v['id'] as num).toInt(),
                              ),
                            ),
                            child: const Text('Bayar'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Payment UI generik (tidak hardcode gateway). pending/success/failed/expired/cancelled
/// dibaca ulang dari server. Idempotency key auto uuid.
class _PayDialog extends ConsumerStatefulWidget {
  const _PayDialog({required this.invoiceId});
  final int invoiceId;
  @override
  ConsumerState<_PayDialog> createState() => _P();
}

class _P extends ConsumerState<_PayDialog> {
  final amount = TextEditingController();
  final method = TextEditingController(text: '1');
  final date = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  final reference = TextEditingController();
  final notes = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Bayar Invoice'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          controller: amount,
          label: 'Amount',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(
          controller: method,
          label: 'payment_method_id',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(controller: date, label: 'payment_date YYYY-MM-DD'),
        const SizedBox(height: 8),
        AppInput(controller: reference, label: 'reference_number (opsional)'),
        const SizedBox(height: 8),
        AppInput(controller: notes, label: 'notes (opsional)'),
        if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () async {
          // Server: PaymentService::process — amount ≤ sisa, lockForUpdate,
          // idempotency_key mengembalikan record sama (anti dobel).
          try {
            await ref
                .read(apiProvider)
                .dio
                .post(
                  R.invoicePay(widget.invoiceId),
                  data: {
                    'amount': num.parse(amount.text),
                    'payment_method_id': int.parse(method.text),
                    'payment_date': date.text, // WAJIB: required|date
                    if (reference.text.isNotEmpty)
                      'reference_number': reference.text,
                    if (notes.text.isNotEmpty) 'notes': notes.text,
                    'idempotency_key': newIdempotencyKey(),
                  },
                  // Server juga menerima header Idempotency-Key sebagai fallback.
                  options: null,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            setState(() => err = '$e');
          }
        },
        child: const Text('Kirim'),
      ),
    ],
  );
}
