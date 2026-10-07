import 'package:flutter/foundation.dart';

/// Safe logging: verbose di dev, minimal di prod.
/// Tidak pernah log password/token/payment secret (caller wajib redaksi).
class Log {
  static void d(String msg) {
    if (kDebugMode) debugPrint('[D] $msg');
  }

  static void i(String msg) {
    if (kDebugMode) debugPrint('[I] $msg');
  }

  static void w(String msg) {
    debugPrint('[W] $msg');
  }

  static void e(String msg) {
    debugPrint('[E] $msg');
  }
}
