import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import 'branch_net.dart';
import '../features/bookings/presentation/bookings_page.dart';
import '../features/customers/presentation/customers_page.dart';
import '../features/estimates/presentation/estimates_page.dart';
import '../features/findings/presentation/findings_page.dart';
import '../features/inspection/presentation/inspection_page.dart';
import '../features/inventory/presentation/inventory_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/tasks/presentation/tasks_page.dart';
import '../features/vehicles/presentation/vehicles_page.dart';
import '../features/approvals/approvals_page.dart';
import '../features/workorders/workorders_page.dart';
import '../features/suppliers/suppliers_page.dart';
import '../features/purchases/purchases_page.dart';
import '../features/warranty/warranty_page.dart';
import '../features/workpackages/workpackages_page.dart';
import '../features/misc/ops_pages.dart';
import '../features/misc/account_pages.dart';
import 'app.dart';

/// Routing terpusat go_router + guard auth.
/// Backend otoritatif; guard hanya UX (sembunyikan + cegah navigasi buta).
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider).valueOrNull;
  return GoRouter(
    initialLocation: auth == null ? '/login' : '/dashboard',
    redirect: (ctx, state) {
      final logged = ref.read(authProvider).valueOrNull != null;
      final atLogin = state.matchedLocation == '/login';
      if (!logged && !atLogin) return '/login';
      if (logged && atLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginRoute()),
      ShellRoute(
        builder: (_, _, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
          GoRoute(path: '/bookings', builder: (_, _) => const BookingsPage()),
          GoRoute(
            path: '/bookings/:id',
            builder: (_, s) =>
                BookingDetail(id: int.parse(s.pathParameters['id']!)),
          ),
          GoRoute(path: '/customers', builder: (_, _) => const CustomersPage()),
          GoRoute(path: '/vehicles', builder: (_, _) => const VehiclesPage()),
          GoRoute(
            path: '/inspections/:id',
            builder: (_, s) =>
                InspectionPage(serviceId: int.parse(s.pathParameters['id']!)),
          ),
          GoRoute(path: '/findings', builder: (_, _) => const FindingsPage()),
          GoRoute(path: '/estimates', builder: (_, _) => const EstimatesPage()),
          GoRoute(
            path: '/estimates/:id',
            builder: (_, s) =>
                EstimateDetail(id: int.parse(s.pathParameters['id']!)),
          ),
          GoRoute(path: '/approvals', builder: (_, _) => const ApprovalsPage()),
          GoRoute(
            path: '/work-orders',
            builder: (_, _) => const WorkOrdersPage(),
          ),
          GoRoute(
            path: '/work-orders/:id',
            builder: (_, s) =>
                WorkOrderDetail(id: int.parse(s.pathParameters['id']!)),
          ),
          GoRoute(path: '/work-tasks', builder: (_, _) => const TasksPage()),
          GoRoute(
            path: '/technicians',
            builder: (_, _) => const TechniciansPage(),
          ),
          GoRoute(path: '/inventory', builder: (_, _) => const InventoryPage()),
          GoRoute(path: '/suppliers', builder: (_, _) => const SuppliersPage()),
          GoRoute(path: '/purchases', builder: (_, _) => const PurchasesPage()),
          GoRoute(path: '/warranty', builder: (_, _) => const WarrantyPage()),
          GoRoute(
            path: '/work-packages',
            builder: (_, _) => const WorkPackagesPage(),
          ),
          GoRoute(path: '/qc', builder: (_, _) => const QcQueuePage()),
          GoRoute(path: '/invoices', builder: (_, _) => const InvoicesPage()),
          GoRoute(path: '/payments', builder: (_, _) => const PaymentsPage()),
          GoRoute(
            path: '/notifications',
            builder: (_, _) => const NotificationsPage(),
          ),
          GoRoute(path: '/reports', builder: (_, _) => const ReportsPage()),
          GoRoute(path: '/branches', builder: (_, _) => const BranchesPage()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          GoRoute(path: '/pos', builder: (_, _) => const PosPage()),
        ],
      ),
    ],
  );
});

class LoginRoute extends ConsumerWidget {
  const LoginRoute({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Scaffold(body: SafeArea(child: _LoginEmbed()));
}

class _LoginEmbed extends ConsumerStatefulWidget {
  const _LoginEmbed();
  @override
  ConsumerState<_LoginEmbed> createState() => _LE();
}

class _LE extends ConsumerState<_LoginEmbed> {
  final e = TextEditingController();
  final p = TextEditingController();
  String? err;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Bengkel Paten',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: e,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          controller: p,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref
                  .read(authProvider.notifier)
                  .login(e.text.trim(), p.text);
              if (context.mounted) context.go('/dashboard');
            } catch (ex) {
              setState(() => err = '$ex');
            }
          },
          child: const Text('Masuk'),
        ),
      ],
    ),
  );
}

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Bengkel Paten'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async => ref.read(authProvider.notifier).logout(),
        ),
      ],
    ),
    body: Column(
      children: [
        const ConnectivityBanner(),
        Expanded(child: child),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      onDestinationSelected: (i) => context.go(
        [
          '/dashboard',
          '/bookings',
          '/estimates',
          '/work-tasks',
          '/invoices',
        ][i],
      ),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dash'),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: 'Booking',
        ),
        NavigationDestination(icon: Icon(Icons.request_quote), label: 'Est'),
        NavigationDestination(icon: Icon(Icons.build), label: 'Tasks'),
        NavigationDestination(icon: Icon(Icons.receipt), label: 'Inv'),
      ],
    ),
  );
}
