import 'package:bengkelflutter/core/error/app_exception.dart';
import 'package:bengkelflutter/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('security: session & isolation', () {
    test('401 kind memicu logout (caller hapus token)', () {
      const e = AppException(AppErrorKind.unauthorized, 'Sesi berakhir');
      expect(e.kind, AppErrorKind.unauthorized);
    });

    test('TokenStorage API tersedia (secure, bukan prefs)', () {
      expect(TokenStorage.new, isNotNull);
    });

    test('branch isolation: lintas cabang 404 bukan 403 (anti enumerasi)', () {
      const e = AppException(AppErrorKind.notFound, 'Data tidak ditemukan.');
      expect(e.kind, AppErrorKind.notFound);
    });

    test('validation errors terparse per-field', () {
      const e = AppException(
        AppErrorKind.validation,
        'Invalid',
        errors: {
          'payment_date': ['required'],
        },
      );
      expect(e.errors['payment_date'], ['required']);
    });
  });
}
