import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/providers.dart';
import '../app/theme.dart';
import '../core/error/app_exception.dart';
import '../domain/entities/roles.dart';
import '../l10n/tr.dart';
import '../shared/widgets/components.dart';
import '../features/customers/presentation/customers_page.dart';
import '../features/vehicles/presentation/vehicles_page.dart';
import '../features/bookings/presentation/bookings_page.dart';
import '../features/estimates/presentation/estimates_page.dart';
import '../features/tasks/presentation/tasks_page.dart';
import '../features/inventory/presentation/inventory_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/notifications/presentation/notifications_page.dart';

/// App root dengan Tr (ID/EN) + theme light/dark + bottom nav role-based.
class BengkelApp extends ConsumerStatefulWidget {
  const BengkelApp({super.key});
  @override
  ConsumerState<BengkelApp> createState() => _S();
}

class _S extends ConsumerState<BengkelApp> {
  Locale locale = const Locale('id');
  ThemeMode mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return TrScope(
      tr: Tr(locale),
      child: MaterialApp(
        title: 'Bengkel Paten',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: auth.when(
          data: (u) => u == null
              ? LoginPage(
                  onLocale: () => setState(
                    () => locale = locale.languageCode == 'id'
                        ? const Locale('en')
                        : const Locale('id'),
                  ),
                )
              : HomeShell(
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                  onToggleTheme: () => setState(
                    () => mode = mode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  ),
                  onLocale: () => setState(
                    () => locale = locale.languageCode == 'id'
                        ? const Locale('en')
                        : const Locale('id'),
                  ),
                ),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => LoginPage(onLocale: () {}),
        ),
      ),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, required this.onLocale});
  final VoidCallback onLocale;
  @override
  ConsumerState<LoginPage> createState() => _L();
}

class _L extends ConsumerState<LoginPage> {
  final e = TextEditingController();
  final p = TextEditingController();
  String? err;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.login),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onLocale,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppInput(
              controller: e,
              label: context.tr.email,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppInput(controller: p, label: context.tr.password, obscure: true),
            if (err != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(err!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            busy
                ? const CircularProgressIndicator()
                : AppButton(
                    label: context.tr.login,
                    onPressed: () async {
                      setState(() {
                        busy = true;
                        err = null;
                      });
                      try {
                        await ref
                            .read(authProvider.notifier)
                            .login(e.text.trim(), p.text);
                      } on AppException catch (ex) {
                        setState(() => err = ex.message);
                      } catch (ex) {
                        setState(() => err = '$ex');
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({
    super.key,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onLocale,
  });
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final VoidCallback onLocale;
  @override
  ConsumerState<HomeShell> createState() => _H();
}

class _H extends ConsumerState<HomeShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final roles = user?.roles ?? [];
    // Role-based tabs: mekanik fokus tasks, kasir fokus invoices, dst.
    final isMechanic =
        roles.contains(Roles.mekanik) && !Roles.unrestricted(roles);
    final tabs = isMechanic
        ? const [TasksPage(), InventoryPage(), NotificationsPage()]
        : const [
            DashboardPage(),
            BookingsPage(),
            EstimatesPage(),
            TasksPage(),
            InvoicesPage(),
          ];
    final labels = isMechanic
        ? [context.tr.tasks, context.tr.inventory, context.tr.notifications]
        : [
            context.tr.dashboard,
            context.tr.bookings,
            context.tr.estimates,
            context.tr.tasks,
            context.tr.invoices,
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text('${user?.name ?? ''} • ${roles.join(', ')}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onLocale,
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: IndexedStack(index: idx, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: [
          for (final l in labels)
            NavigationDestination(icon: const Icon(Icons.circle), label: l),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              title: Text(context.tr.customers),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersPage()),
              ),
            ),
            ListTile(
              title: Text(context.tr.vehicles),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VehiclesPage()),
              ),
            ),
            ListTile(
              title: Text(context.tr.inventory),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryPage()),
              ),
            ),
            ListTile(
              title: Text(context.tr.notifications),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final roles = user?.roles ?? [];
    return FutureBuilder(
      future: ref.watch(genericRemoteProvider).detail(R.dashboardStats),
      builder: (c, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const AppLoadingList();
        }
        if (s.hasError) {
          return AppErrorState(
            message: '${s.error}',
            onRetry: () => (c as Element).markNeedsBuild(),
          );
        }
        final d = s.data ?? {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.tr.dashboard,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            // Manager: revenue/outstanding/utilization. Advisor: bookings/approval.
            // Mekanik: tasks/timer/QC. Render apa yang dikembalikan server.
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roles: ${roles.join(', ')}'),
                  const SizedBox(height: 8),
                  Text('$d', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingsPage()),
                  ),
                  child: Text(context.tr.bookings),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EstimatesPage()),
                  ),
                  child: Text(context.tr.estimates),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TasksPage()),
                  ),
                  child: Text(context.tr.tasks),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
