import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Gerbang izin per-fitur (kamera hanya saat fitur kamera dipanggil).
/// Menangani: granted, denied (minta lagi), permanentlyDenied (arahkan ke setting).
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.rationale = 'Izin diperlukan untuk fitur ini.',
  });
  final Permission permission;
  final Widget child;
  final String rationale;

  Future<PermissionStatus> _status() => permission.status;

  @override
  Widget build(BuildContext context) => FutureBuilder<PermissionStatus>(
    future: _status(),
    builder: (_, s) {
      final st = s.data;
      if (st == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (st.isGranted || st.isLimited) return child;
      if (st.isPermanentlyDenied) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rationale, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const ElevatedButton(
                onPressed: openAppSettings,
                child: Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rationale, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await permission.request();
                (context as Element).markNeedsBuild();
              },
              child: const Text('Beri Izin'),
            ),
          ],
        ),
      );
    },
  );
}
