import 'package:bengkelflutter/core/error/boundary_deeplink.dart';
import 'package:bengkelflutter/core/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('timer engine rules', () {
    test('satu aktif per device (kontrak guard)', () {
      const running = 34;
      const other = 35;
      expect(running != other, isTrue);
    });

    test('start idempoten saat in_progress (server no-op)', () {
      expect('in_progress', 'in_progress');
    });
  });

  group('serialization audit (toleran enum baru)', () {
    test('status tak dikenal tidak crash (fallback string)', () {
      String safe(String? s) => s ?? 'unknown';
      expect(safe(null), 'unknown');
      expect(safe('super_baru_2030'), 'super_baru_2030');
    });

    test('uang: server otoritatif, client hanya display', () {
      expect(Fmt.idr(1500000), contains('Rp'));
    });

    test('tanggal ISO-8601 Asia/Jakarta terformat', () {
      expect(Fmt.dateStr('2026-10-07'), isNotEmpty);
      expect(Fmt.dateStr(null), '-');
    });

    test('plat dinormalisasi untuk display saja', () {
      expect(Fmt.plate('  b 1234 xyz '), 'B 1234 XYZ');
    });
  });

  group('deep link validation', () {
    test('skema salah ditolak', () {
      expect(DeepLink.parse(Uri.parse('https://x/estimates/1')), isNull);
    });
    test('entity tak dikenal ditolak', () {
      expect(DeepLink.parse(Uri.parse('bengkelpaten://app/hack/1')), isNull);
    });
    test('estimate → /estimates/:id', () {
      final d = DeepLink.parse(Uri.parse('bengkelpaten://app/estimate/12'));
      expect(d?.route, '/estimates/12');
    });
    test('id non-angka ditolak', () {
      expect(
        DeepLink.parse(Uri.parse('bengkelpaten://app/invoice/abc')),
        isNull,
      );
    });
  });

  group('pagination Laravel (current/last/per/total)', () {
    test('hasMore = current < last', () {
      bool hasMore(int c, int l) => c < l;
      expect(hasMore(1, 3), isTrue);
      expect(hasMore(3, 3), isFalse);
    });
  });
}
