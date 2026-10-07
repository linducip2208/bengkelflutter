import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/roles.dart';
import '../../../shared/widgets/components.dart';

/// QC: checklist pass/fail notes photos rework. Cegah rilis sebelum QC lulus.
class QcSheet extends ConsumerStatefulWidget {
  const QcSheet({super.key, required this.packageId});
  final int packageId;
  @override
  ConsumerState<QcSheet> createState() => _Q();
}

class _Q extends ConsumerState<QcSheet> {
  final notes = TextEditingController();
  bool passed = true;
  String? err;
  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(authProvider).valueOrNull?.roles ?? [];
    if (!Roles.canQc(roles)) return const Text('Tidak berhak QC.');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          value: passed,
          onChanged: (v) => setState(() => passed = v),
          title: Text(passed ? 'PASS' : 'FAIL'),
        ),
        AppInput(controller: notes, label: 'Notes (wajib jika FAIL)'),
        if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        AppButton(
          label: 'Submit QC',
          onPressed: () async {
            if (!passed && notes.text.isEmpty) {
              setState(() => err = 'QC gagal wajib notes.');
              return;
            }
            try {
              await ref
                  .read(apiProvider)
                  .dio
                  .post(
                    R.workPackageQc(widget.packageId),
                    data: {
                      'result': passed ? 'passed' : 'failed',
                      'notes': notes.text,
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
}
