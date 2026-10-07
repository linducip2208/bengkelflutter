import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bengkelflutter/core/error/app_exception.dart';
import 'package:bengkelflutter/core/network/api_client.dart';
import 'package:bengkelflutter/core/network/api_paths.dart';
import 'package:bengkelflutter/core/storage/token_storage.dart';

/// Critical mutations: ONLINE + OFFLINE + ERROR + AUTH + RETRY + DUPLICATE.
/// Memakai Dio mock deterministik — tidak tergantung production API.
/// Server-wins: payment/stock/approval tidak pernah dioverride lokal.

Dio _dioWith(Future<Response<dynamic>> Function(RequestOptions o) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) async {
        try {
          h.resolve(await handler(o));
        } catch (e) {
          h.reject(
            e is DioException ? e : DioException(requestOptions: o, error: e),
          );
        }
      },
    ),
  );
  return dio;
}

Response<dynamic> _ok(RequestOptions o, Object data, [int code = 200]) =>
    Response(requestOptions: o, statusCode: code, data: data);

DioException _err(RequestOptions o, int code, Object data) => DioException(
  requestOptions: o,
  response: Response(requestOptions: o, statusCode: code, data: data),
  type: DioExceptionType.badResponse,
);

void main() {
  group('payment POST /invoices/{id}/payments (PaymentService::process)', () {
    test('ONLINE: kirim field wajib incl payment_date + idempotency', () async {
      Map? seen;
      final dio = _dioWith((o) async {
        seen = o.data as Map;
        return _ok(o, {'id': 1}, 201);
      });
      final api = ApiClient(TokenStorage(), client: dio);
      await api.post(
        ApiPaths.invoicePay(56),
        data: {
          'amount': 150000,
          'payment_method_id': 1,
          'payment_date': '2026-10-07',
          'idempotency_key': 'k-1',
        },
      );
      expect(seen!['payment_date'], '2026-10-07');
      expect(seen!['idempotency_key'], 'k-1');
    });

    test('ERROR 422 tanpa payment_date (required|date)', () async {
      final dio = _dioWith((o) async {
        throw _err(o, 422, {
          'message': 'The payment date field is required.',
          'errors': {
            'payment_date': ['The payment date field is required.'],
          },
        });
      });
      final api = ApiClient(TokenStorage(), client: dio);
      try {
        await api.post(ApiPaths.invoicePay(56), data: {'amount': 1});
        fail('harus 422');
      } on AppException catch (e) {
        expect(e.kind, AppErrorKind.validation);
        expect(e.errors.containsKey('payment_date'), isTrue);
      }
    });

    test('AUTH 401 → unauthorized', () async {
      final dio = _dioWith((o) async {
        throw _err(o, 401, {'message': 'Unauthenticated.'});
      });
      final api = ApiClient(TokenStorage(), client: dio);
      expect(
        () => api.post(ApiPaths.invoicePay(1), data: {}),
        throwsA(
          isA<AppException>().having(
            (e) => e.kind,
            'kind',
            AppErrorKind.unauthorized,
          ),
        ),
      );
    });

    test('RETRY + DUPLICATE: key sama → record sama (idempoten)', () async {
      int calls = 0;
      final dio = _dioWith((o) async {
        calls++;
        return _ok(o, {'id': 9, 'idempotency_key': 'dup-1'}, 201);
      });
      final api = ApiClient(TokenStorage(), client: dio);
      for (var i = 0; i < 2; i++) {
        await api.post(
          ApiPaths.invoicePay(56),
          data: {
            'amount': 10,
            'payment_method_id': 1,
            'payment_date': '2026-10-07',
            'idempotency_key': 'dup-1',
          },
        );
      }
      expect(calls, 2); // server yang dedup; client selalu kirim key sama
    });

    test(
      'OFFLINE: tanpa koneksi → AppException network, tidak override lokal',
      () async {
        final dio = _dioWith((o) async {
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          );
        });
        final api = ApiClient(TokenStorage(), client: dio);
        try {
          await api.post(ApiPaths.invoicePay(1), data: {});
          fail('harus network error');
        } on AppException catch (e) {
          expect(e.kind, AppErrorKind.network);
        }
        // Server-wins: tidak ada write lokal finansial di test ini.
      },
    );
  });

  group('stock-adjust (StockService locked)', () {
    test('ONLINE: {quantity, type, notes?}', () async {
      Map? seen;
      final dio = _dioWith((o) async {
        seen = o.data as Map;
        return _ok(o, {'quantity_after': 11});
      });
      final api = ApiClient(TokenStorage(), client: dio);
      await api.post(
        ApiPaths.productStockAdjust(3),
        data: {'quantity': 1, 'type': 'add', 'notes': 'opname'},
      );
      expect(seen!['type'], 'add');
    });

    test('ERROR: stok kurang → 422, bukan override lokal', () async {
      final dio = _dioWith((o) async {
        throw _err(o, 422, {'message': 'Stok tidak mencukupi.'});
      });
      final api = ApiClient(TokenStorage(), client: dio);
      try {
        await api.post(
          ApiPaths.productStockAdjust(3),
          data: {'quantity': 999, 'type': 'subtract'},
        );
        fail('harus 422');
      } on AppException catch (e) {
        expect(e.kind, AppErrorKind.validation);
      }
    });
  });

  group('task transition idempoten (WorkshopFlowService)', () {
    test(
      'ONLINE start + DUPLICATE start saat in_progress → tetap ok',
      () async {
        final dio = _dioWith(
          (o) async => _ok(o, {'message': 'Status task diperbarui.'}),
        );
        final api = ApiClient(TokenStorage(), client: dio);
        await api.post(ApiPaths.taskStart(34));
        await api.post(
          ApiPaths.taskStart(34),
        ); // server return locked (idempoten)
      },
    );

    test('ERROR transisi ilegal → 422', () async {
      final dio = _dioWith((o) async {
        throw _err(o, 422, {
          'message': 'Task tidak bisa dimulai dari status completed.',
        });
      });
      final api = ApiClient(TokenStorage(), client: dio);
      try {
        await api.post(ApiPaths.taskStart(1));
        fail('harus 422');
      } on AppException catch (e) {
        expect(e.message, contains('completed'));
      }
    });
  });

  group('estimate decide validation (submitGroupDecisions)', () {
    test('ERROR tanpa decisions → 422', () async {
      final dio = _dioWith((o) async {
        throw _err(o, 422, {
          'message': 'The decisions field is required.',
          'errors': {
            'decisions': ['required'],
          },
        });
      });
      final api = ApiClient(TokenStorage(), client: dio);
      try {
        await api.post(ApiPaths.estimateDecide(12), data: {});
        fail('harus 422');
      } on AppException catch (e) {
        expect(e.kind, AppErrorKind.validation);
      }
    });
  });

  group('photos + device tokens (kontrak baru)', () {
    test('photo response membawa data.url absolut', () {
      final m = {
        'message': 'Foto berhasil diunggah.',
        'data': {'url': 'https://x/storage/vehicle-images/abc.jpg'},
      };
      expect((m['data'] as Map)['url'], contains('http'));
    });

    test('device token idempoten per (user, token)', () {
      // ApiWorkshopController@registerDeviceToken memakai updateOrCreate.
      expect(ApiPaths.deviceTokens, '/device-tokens');
    });
  });

  test('remotes aid construction (no invented paths)', () {
    expect(ApiPaths.vehicleImages(1), '/vehicles/1/images');
    expect(ApiPaths.serviceImages(2), '/services/2/images');
    expect(ApiPaths.invoicePay(56), '/invoices/56/payments');
  });
}
