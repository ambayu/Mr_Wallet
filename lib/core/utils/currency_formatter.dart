import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _rupiahFormat.format(amount);
  }

  static String formatRupiah(double amount) {
    return _rupiahFormat.format(amount);
  }

  static String formatCompact(double amount) {
    return _compactFormat.format(amount);
  }

  static String formatShort(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }
}
