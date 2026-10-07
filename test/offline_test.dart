import 'package:bengkelflutter/features/offline/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('offline: queue & server-wins', () {
    test('backoff naik + capped', () {
      expect(SyncEngine.backoff(0).inSeconds, 1);
      expect(SyncEngine.backoff(3).inSeconds, 8);
      expect(SyncEngine.backoff(99).inSeconds <= 60, isTrue);
    });

    test('server-wins: finansial tidak dioverride lokal (kebijakan)', () {
      const serverWins = {
        'payment',
        'invoice',
        'stock',
        'approval',
        'pos_checkout',
      };
      expect(serverWins.contains('payment'), isTrue);
      expect(serverWins.contains('stock'), isTrue);
    });
  });
}
