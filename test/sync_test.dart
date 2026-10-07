import 'package:flutter_test/flutter_test.dart';
import 'package:bengkelflutter/features/offline/sync_engine.dart';

void main() {
  test('backoff exponential capped', () {
    expect(SyncEngine.backoff(0), const Duration(seconds: 1));
    expect(SyncEngine.backoff(1), const Duration(seconds: 2));
    expect(SyncEngine.backoff(6).inSeconds <= 60, isTrue);
  });
}
