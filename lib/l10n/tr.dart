import 'package:flutter/material.dart';

/// Minimal ID/EN tanpa dependency tambahan. No hardcoded strings di UI penting.
/// Pakai: context.tr.yourKey
class Tr {
  Tr(this.locale);
  final Locale locale;
  bool get id => locale.languageCode == 'id';

  String get login => id ? 'Masuk' : 'Login';
  String get email => 'Email';
  String get password => id ? 'Kata sandi' : 'Password';
  String get dashboard => id ? 'Dasbor' : 'Dashboard';
  String get retry => id ? 'Coba lagi' : 'Retry';
  String get logout => id ? 'Keluar' : 'Logout';
  String get customers => id ? 'Pelanggan' : 'Customers';
  String get vehicles => id ? 'Kendaraan' : 'Vehicles';
  String get bookings => id ? 'Booking' : 'Bookings';
  String get estimates => id ? 'Estimasi' : 'Estimates';
  String get tasks => id ? 'Tugas' : 'Tasks';
  String get inventory => id ? 'Inventaris' : 'Inventory';
  String get invoices => id ? 'Faktur' : 'Invoices';
  String get payments => id ? 'Pembayaran' : 'Payments';
  String get notifications => id ? 'Notifikasi' : 'Notifications';
}

class TrScope extends InheritedWidget {
  const TrScope({super.key, required this.tr, required super.child});
  final Tr tr;
  static Tr of(BuildContext c) =>
      (c.dependOnInheritedWidgetOfExactType<TrScope>()!).tr;
  @override
  bool updateShouldNotify(TrScope old) => tr.locale != old.tr.locale;
}

extension TrX on BuildContext {
  Tr get tr => TrScope.of(this);
}
