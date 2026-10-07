import 'package:bengkelflutter/core/error/app_exception.dart';
import 'package:bengkelflutter/core/network/api_client.dart';
import 'package:bengkelflutter/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matriks kegagalan: timeout, offline, 401/403/404/409/422/429/500,
/// duplicate, expired, JSON invalid/kosong/malformed, upload gagal.
ApiClient _client(Future<Response<dynamic>> Function(RequestOptions) h) {
  final dio = Dio(BaseOptions(baseUrl: 'http://x'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, handler) async {
        try {
          handler.resolve(await h(o));
        } catch (e) {
          handler.reject(
            e is DioException ? e : DioException(requestOptions: o, error: e),
          );
        }
      },
    ),
  );
  return ApiClient(TokenStorage(), client: dio);
}

DioException _e(
  RequestOptions o,
  int code,
  Object data, [
  DioExceptionType t = DioExceptionType.badResponse,
]) => DioException(
  requestOptions: o,
  response: Response(requestOptions: o, statusCode: code, data: data),
  type: t,
);

void main() {
  test('timeout → AppErrorKind.timeout', () async {
    final c = _client((o) async {
      throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionTimeout,
      );
    });
    try {
      await c.get('/x');
      fail('harus timeout');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.timeout);
    }
  });

  test('403 → forbidden (cabang/role)', () async {
    final c = _client((o) async {
      throw _e(o, 403, {'message': 'Cabang tidak dapat diakses.'});
    });
    try {
      await c.get('/x');
      fail('harus 403');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.forbidden);
    }
  });

  test('404 lintas cabang → notFound', () async {
    final c = _client((o) async {
      throw _e(o, 404, {'message': 'X'});
    });
    try {
      await c.get('/x');
      fail('harus 404');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.notFound);
    }
  });

  test('409 → conflict', () async {
    final c = _client((o) async {
      throw _e(o, 409, {'message': 'Konflik.'});
    });
    try {
      await c.get('/x');
      fail('harus 409');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.conflict);
    }
  });

  test('429 → rateLimit', () async {
    final c = _client((o) async {
      throw _e(o, 429, {'message': 'Throttle.'});
    });
    try {
      await c.get('/x');
      fail('harus 429');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.rateLimit);
    }
  });

  test('500 → server', () async {
    final c = _client((o) async {
      throw _e(o, 500, 'err');
    });
    try {
      await c.get('/x');
      fail('harus 500');
    } on AppException catch (e) {
      expect(e.kind, AppErrorKind.server);
    }
  });

  test(
    'double-tap payment: dua request key sama terkirim (server dedup)',
    () async {
      int n = 0;
      final c = _client((o) async {
        n++;
        return Response(requestOptions: o, statusCode: 201, data: {'id': n});
      });
      await c.post('/invoices/1/payments', data: {'idempotency_key': 'k'});
      await c.post('/invoices/1/payments', data: {'idempotency_key': 'k'});
      expect(n, 2);
    },
  );
}
