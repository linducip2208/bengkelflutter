/// Laravel paginator apa adanya + detail {data} + aksi {message,data}.
class ApiPage<T> {
  const ApiPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  bool get hasMore => currentPage < lastPage;

  static ApiPage<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) f,
  ) {
    final raw = (json['data'] as List? ?? []);
    return ApiPage<T>(
      items: raw.map((e) => f(e as Map<String, dynamic>)).toList(),
      currentPage: (json['current_page'] as num? ?? 1).toInt(),
      lastPage: (json['last_page'] as num? ?? 1).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
      perPage: (json['per_page'] as num? ?? 20).toInt(),
    );
  }
}

Map<String, dynamic> unwrapData(Map<String, dynamic> json) =>
    json['data'] is Map<String, dynamic>
    ? json['data'] as Map<String, dynamic>
    : json;
