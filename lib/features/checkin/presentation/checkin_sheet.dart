import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/providers.dart';
import '../../../config/app_env.dart';
import '../../../shared/widgets/components.dart';

/// Check-in: customer, vehicle, mileage, complaint, photos, notes, branch, advisor.
/// Konfirmasi sebelum submit. Foto dikompres caller; hormati maxUploadBytes.
class CheckinSheet extends ConsumerStatefulWidget {
  const CheckinSheet({super.key});
  @override
  ConsumerState<CheckinSheet> createState() => _C();
}

class _C extends ConsumerState<CheckinSheet> {
  final mileage = TextEditingController();
  final complaint = TextEditingController();
  final notes = TextEditingController();
  XFile? photo;
  String? err;

  Future<void> pick() async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
      setState(() => err = 'Izin kamera ditolak.');
      return;
    }
    final f = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (f != null) {
      final bytes = await f.length();
      if (bytes > AppEnv.maxUploadBytes) {
        setState(() => err = 'Foto terlalu besar.');
        return;
      }
      setState(() => photo = f);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInput(
          controller: mileage,
          label: 'Mileage',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 8),
        AppInput(controller: complaint, label: 'Keluhan'),
        const SizedBox(height: 8),
        AppInput(controller: notes, label: 'Catatan'),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: pick,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Foto'),
            ),
            const SizedBox(width: 8),
            Text(photo?.name ?? 'Belum ada foto'),
          ],
        ),
        if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        AppButton(
          label: 'Konfirmasi & Submit',
          onPressed: () async {
            final ok = await confirmDialog(
              context,
              'Check-in',
              'Submit check-in ini?',
            );
            if (ok != true) return;
            try {
              await ref
                  .read(apiProvider)
                  .dio
                  .post(
                    R.jobcards,
                    data: {
                      'mileage': mileage.text,
                      'complaint': complaint.text,
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
    ),
  );
}
