import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../app/providers.dart';
import '../../shared/widgets/design_extra.dart';

/// Invoice PDF — download terautentikasi (Dio bytes + Bearer interceptor),
/// simpan ke dokumen aplikasi. Dokumen privat tidak lewat URL publik.
/// Share ke aplikasi lain: P2 (tambah share_plus bila dibutuhkan).
class InvoicePdfButton extends ConsumerStatefulWidget {
  const InvoicePdfButton({super.key, required this.invoiceId});
  final int invoiceId;
  @override
  ConsumerState<InvoicePdfButton> createState() => _IP();
}

class _IP extends ConsumerState<InvoicePdfButton> {
  bool busy = false;
  @override
  Widget build(BuildContext context) => busy
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : TextButton(
          onPressed: () async {
            setState(() => busy = true);
            try {
              final res = await ref
                  .read(apiProvider)
                  .dio
                  .get<List<int>>(
                    R.invoicePdf(widget.invoiceId),
                    options: Options(responseType: ResponseType.bytes),
                  );
              final dir = await getApplicationDocumentsDirectory();
              final path = '${dir.path}/invoice-${widget.invoiceId}.pdf';
              await File(path).writeAsBytes(res.data ?? []);
              if (context.mounted) appSnack(context, 'PDF tersimpan: $path');
            } catch (e) {
              if (context.mounted) appSnack(context, '$e', error: true);
            } finally {
              if (mounted) setState(() => busy = false);
            }
          },
          child: const Text('PDF'),
        );
}
