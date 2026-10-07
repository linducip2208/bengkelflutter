import 'package:flutter/material.dart';

/// Batas error global: fallback aman, tanpa stacktrace ke user.
/// Dipasang via ErrorWidget.builder + FlutterError.onError di main.
class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({super.key, this.details});
  final String? details;
  @override
  Widget build(BuildContext context) => Material(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Terjadi kesalahan tak terduga.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai ulang aplikasi. Data tersimpan aman di server.',
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 12),
              Text(
                details!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Deep link bengkelpaten://app/{entity}/{id} + validasi.
/// Auth + otorisasi dicek sebelum konten protektif; resource hilang → pesan aman.
class DeepLink {
  const DeepLink({required this.entity, required this.id});
  final String entity;
  final int id;

  static const allowed = {
    'booking',
    'estimate',
    'approval',
    'invoice',
    'payment',
    'work-order',
    'notification',
  };

  static DeepLink? parse(Uri uri) {
    if (uri.scheme != 'bengkelpaten') return null;
    final seg = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (seg.length != 2) return null;
    if (!allowed.contains(seg[0])) return null;
    final id = int.tryParse(seg[1]);
    if (id == null) return null;
    return DeepLink(entity: seg[0], id: id);
  }

  /// Route internal go_router untuk entity.
  String get route => switch (entity) {
    'booking' => '/bookings/$id',
    'estimate' || 'approval' => '/estimates/$id',
    'invoice' || 'payment' => '/invoices',
    'work-order' => '/work-orders/$id',
    _ => '/notifications',
  };
}
