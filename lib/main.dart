import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'l10n/tr.dart';

void main() {
  runApp(const ProviderScope(child: BengkelRoot()));
}

class BengkelRoot extends ConsumerWidget {
  const BengkelRoot({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return TrScope(
      tr: Tr(const Locale('id')),
      child: MaterialApp.router(
        title: 'Bengkel Paten',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: router,
      ),
    );
  }
}
