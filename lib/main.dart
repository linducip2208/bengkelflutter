import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/lifecycle.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/error/boundary_deeplink.dart';
import 'features/timer/timer_engine.dart';
import 'l10n/tr.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      ErrorWidget.builder = (details) => const AppErrorScreen();
      runApp(const ProviderScope(child: BengkelRoot()));
    },
    (error, stack) {
      debugPrint('[FATAL] $error');
    },
  );
}

class BengkelRoot extends ConsumerWidget {
  const BengkelRoot({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return AppLifecycle(
      onResume: () async {
        // Pulih sesi + timer + antrean setelah suspend.
        await ref.read(timerProvider.notifier).syncFromServer();
      },
      child: TrScope(
        tr: Tr(const Locale('id')),
        child: MaterialApp.router(
          title: 'Bengkel Paten',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
  }
}
