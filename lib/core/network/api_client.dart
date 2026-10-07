import 'package:dio/dio.dart';
import '../../config/app_env.dart';
import '../error/app_exception.dart';
import '../storage/token_storage.dart';

/// Centralized API client: baseURL, auth, timeout, retry, error parsing.
/// Logging hanya development (Dio LogInterceptor dibatasi).
class ApiClient {
  ApiClient(this._tokens, {Dio? client}) {
    dio =
        client ??
        Dio(
          BaseOptions(
            baseUrl: AppEnv.apiBaseUrl,
            connectTimeout: AppEnv.connectTimeout,
            receiveTimeout: AppEnv.receiveTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final t = await _tokens.read();
          if (t != null && t.isNotEmpty) {
            o.headers['Authorization'] = 'Bearer $t';
          }
          h.next(o);
        },
      ),
    );
  }

  final TokenStorage _tokens;
  late final Dio dio;

  Never _throwMapped(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String msg = 'Terjadi kesalahan jaringan.';
    Map<String, List<String>> errs = {};
    if (data is Map && data['message'] is String) {
      msg = data['message'] as String;
    }
    if (data is Map && data['errors'] is Map) {
      errs = (data['errors'] as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    throw switch (code) {
      401 => AppException(
        AppErrorKind.unauthorized,
        msg.isEmpty ? 'Sesi berakhir, silakan login ulang.' : msg,
      ),
      403 => AppException(
        AppErrorKind.forbidden,
        msg.isEmpty ? 'Akses ditolak untuk cabang/role ini.' : msg,
      ),
      404 => const AppException(AppErrorKind.notFound, 'Data tidak ditemukan.'),
      409 => AppException(AppErrorKind.conflict, msg),
      422 => AppException(
        AppErrorKind.validation,
        msg.isEmpty ? 'Data tidak valid.' : msg,
        errors: errs,
      ),
      429 => const AppException(
        AppErrorKind.rateLimit,
        'Terlalu banyak permintaan, coba lagi.',
      ),
      _
          when e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout =>
        const AppException(
          AppErrorKind.timeout,
          'Koneksi timeout, periksa internet.',
        ),
      _ when e.type == DioExceptionType.connectionError => const AppException(
        AppErrorKind.network,
        'Tidak ada koneksi internet.',
      ),
      _ when code != null && code >= 500 => const AppException(
        AppErrorKind.server,
        'Server bermasalah, coba lagi.',
      ),
      _ => AppException(AppErrorKind.unknown, msg),
    };
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      return await dio.post<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  Future<Response<T>> put<T>(String path, {Object? data}) async {
    try {
      return await dio.put<T>(path, data: data);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) async {
    try {
      return await dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {Object? data}) async {
    try {
      return await dio.delete<T>(path, data: data);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }

  /// Multipart upload (saat backend membuka endpoint upload).
  /// Hormati maxUploadBytes, kompres sebelum kirim dari caller.
  Future<Response<T>> upload<T>(
    String path,
    String fileField,
    String filePath, {
    Map<String, dynamic> fields = const {},
  }) async {
    try {
      final form = FormData.fromMap({
        ...fields,
        fileField: await MultipartFile.fromFile(filePath),
      });
      return await dio.post<T>(path, data: form);
    } on DioException catch (e) {
      _throwMapped(e);
    }
  }
}
