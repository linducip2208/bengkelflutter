import 'package:flutter/material.dart';
import 'design_system.dart';

/// Lanjutan design system: field, dropdown, date, search, snackbar,
/// avatar, section, stat, list, filter, elevation, icons.
abstract final class AppElevation {
  static const card = 1.0;
  static const sheet = 4.0;
  static const dialog = 8.0;
}

abstract final class AppIcons {
  static const dashboard = Icons.dashboard_outlined;
  static const booking = Icons.calendar_month_outlined;
  static const customer = Icons.people_outline;
  static const vehicle = Icons.directions_car_outlined;
  static const task = Icons.build_outlined;
  static const inventory = Icons.inventory_2_outlined;
  static const invoice = Icons.receipt_long_outlined;
  static const bell = Icons.notifications_outlined;
  static const branch = Icons.store_outlined;
  static const report = Icons.bar_chart_outlined;
  static const profile = Icons.person_outline;
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboard,
    this.obscure = false,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final bool obscure;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hint = 'Cari...',
  });
  final TextEditingController controller;
  final String hint;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    items: items,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label),
  );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: AppTypography.h2)),
      ?action,
    ],
  );
}

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.h2),
              Text(label, style: AppTypography.caption),
            ],
          ),
        ],
      ),
    ),
  );
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) =>
      CircleAvatar(child: Text(name.isEmpty ? '?' : name[0].toUpperCase()));
}

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final c in children)
          Padding(padding: const EdgeInsets.only(right: 8), child: c),
      ],
    ),
  );
}

void appSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : null,
    ),
  );
}

/// Guard presentasi (bukan security boundary — server otoritatif).
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.roles,
    required this.allowed,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });
  final List<String> roles;
  final List<String> allowed;
  final Widget child;
  final Widget fallback;
  @override
  Widget build(BuildContext context) {
    if (roles.contains('super_admin') || roles.contains('admin')) {
      return child;
    }
    return roles.any(allowed.contains) ? child : fallback;
  }
}
