import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Siklus hidup aplikasi: resume → sinkron sesi + timer + antrean.
/// Upload/sync/auth pulih grasi setelah suspend.
class AppLifecycle extends ConsumerStatefulWidget {
  const AppLifecycle({super.key, required this.child, this.onResume});
  final Widget child;
  final Future<void> Function()? onResume;
  @override
  ConsumerState<AppLifecycle> createState() => _AL();
}

class _AL extends ConsumerState<AppLifecycle> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await widget.onResume?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
