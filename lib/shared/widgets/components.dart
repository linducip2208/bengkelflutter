import 'package:flutter/material.dart';
import 'design_system.dart';

/// Komponen konsisten: buttons, cards, inputs, dialogs, sheets, badge, states, appbar.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? AppColors.danger : AppColors.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Text(label),
    ),
  );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboard,
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboard;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );
}

/// Status colors konsisten untuk estimate/task/invoice/payment.
Color statusColor(String s) {
  final v = s.toLowerCase();
  if (v.contains('approve') ||
      v.contains('pass') ||
      v.contains('paid') ||
      v.contains('success') ||
      v == 'completed') {
    return AppColors.success;
  }
  if (v.contains('wait') ||
      v.contains('pending') ||
      v.contains('draft') ||
      v.contains('sent')) {
    return AppColors.warning;
  }
  if (v.contains('reject') || v.contains('fail') || v.contains('expired')) {
    return AppColors.danger;
  }
  return AppColors.info;
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 48, color: AppColors.muted),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.h2),
        if (subtitle != null) Text(subtitle!, style: AppTypography.muted),
      ],
    ),
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}

class AppLoadingList extends StatelessWidget {
  const AppLoadingList({super.key});
  @override
  Widget build(BuildContext context) => ListView.builder(
    shrinkWrap: true,
    itemCount: 5,
    itemBuilder: (_, _) => const Card(
      child: ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Memuat...'),
      ),
    ),
  );
}

Future<bool?> confirmDialog(BuildContext ctx, String title, String msg) =>
    showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

Future<void> appBottomSheet(BuildContext ctx, Widget child) =>
    showModalBottomSheet<void>(
      context: ctx,
      showDragHandle: true,
      builder: (_) => Padding(padding: const EdgeInsets.all(16), child: child),
    );
