/// Centralized error taxonomy. Setiap screen pakai ini + recovery, bukan raw stacktrace.
enum AppErrorKind {
  network,
  timeout,
  unauthorized, // 401 -> logout + hapus token
  forbidden, // 403 branch/role
  validation, // 422 + errors map
  notFound, // 404 (lintas cabang = 404 anti enumerasi)
  conflict, // 409
  rateLimit, // 429
  server, // 500
  unknown,
}

class AppException implements Exception {
  const AppException(this.kind, this.message, {this.errors = const {}});
  final AppErrorKind kind;
  final String message;
  final Map<String, List<String>> errors;

  @override
  String toString() => message;
}

String validationSummary(Map<String, List<String>> errors) {
  if (errors.isEmpty) return '';
  return errors.entries
      .map((e) => '${e.key}: ${e.value.join(', ')}')
      .join('\n');
}
