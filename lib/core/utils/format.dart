import 'package:intl/intl.dart';

/// Formatter konsisten: IDR, tanggal Asia/Jakarta, desimal stok.
/// Default id-ID; fleksibel via locale param.
/// Tidak memakai double untuk state finansial otoritatif (hanya display).
class Fmt {
  static final _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  static final _num = NumberFormat.decimalPattern('id_ID');
  static final _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dt = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

  static String idr(num? v) => v == null ? '-' : _idr.format(v);
  static String number(num? v) => v == null ? '-' : _num.format(v);
  static String dateStr(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      return _date.format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  static String dateTimeStr(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      return _dt.format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  /// Normalisasi plat tanpa merusak nilai tersimpan (display/helper saja).
  static String plate(String? raw) =>
      (raw ?? '').toUpperCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
