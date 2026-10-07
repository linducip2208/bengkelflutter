import 'package:flutter/material.dart';

/// Design tokens — jangan hardcode style di screen.
// ignore_for_file: avoid_classes_with_only_static_members
abstract final class AppColors {
  static const primary = Color(0xFF0B5FFF);
  static const ink = Color(0xFF101828);
  static const muted = Color(0xFF667085);
  static const line = Color(0xFFE4E7EC);
  static const bg = Color(0xFFF6F7F9);
  static const card = Colors.white;
  static const success = Color(0xFF12805C);
  static const warning = Color(0xFFB54708);
  static const danger = Color(0xFFB42318);
  static const info = Color(0xFF175CD3);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const card = BorderRadius.all(Radius.circular(12));
}

abstract final class AppTypography {
  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.ink);
  static const muted = TextStyle(fontSize: 13, color: AppColors.muted);
  static const caption = TextStyle(fontSize: 12, color: AppColors.muted);
}
