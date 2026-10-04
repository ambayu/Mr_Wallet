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

  static String _trimTrailingZero(double val, int decimals) {
    String str = val.toStringAsFixed(decimals);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0*$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }

  static String formatShort(double amount) {
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (absAmount >= 1000000000000) {
      final val = absAmount / 1000000000000;
      return '$sign' 'Rp ${_trimTrailingZero(val, 1)}T';
    } else if (absAmount >= 1000000000) {
      final val = absAmount / 1000000000;
      return '$sign' 'Rp ${_trimTrailingZero(val, 1)}M';
    } else if (absAmount >= 1000000) {
      final val = absAmount / 1000000;
      return '$sign' 'Rp ${_trimTrailingZero(val, 1)}jt';
    } else if (absAmount >= 1000) {
      final val = absAmount / 1000;
      return '$sign' 'Rp ${_trimTrailingZero(val, 0)}rb';
    }
    return format(amount);
  }
}
