import 'package:flutter/material.dart';

/// Pemetaan ikon wadah rekening dari key string (disimpan di DB)
/// ke [IconData]. Dipakai di form tambah wadah dan seluruh tampilan.
class WalletIconHelper {
  WalletIconHelper._();

  /// Ikon yang tersedia untuk dipilih pengguna (urutan tampil di picker).
  static const List<String> options = [
    'payments',
    'account_balance',
    'account_balance_wallet',
    'credit_card',
    'savings',
    'phone_android',
    'wallet',
    'attach_money',
    'storefront',
    'card_giftcard',
    'work',
    'home',
    'favorite',
    'trending_up',
    'redeem',
  ];

  static const Map<String, IconData> _map = {
    'payments': Icons.payments_rounded,
    'account_balance': Icons.account_balance_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'credit_card': Icons.credit_card_rounded,
    'savings': Icons.savings_rounded,
    'phone_android': Icons.phone_android_rounded,
    'wallet': Icons.wallet_rounded,
    'attach_money': Icons.attach_money_rounded,
    'storefront': Icons.storefront_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'work': Icons.work_rounded,
    'home': Icons.home_rounded,
    'favorite': Icons.favorite_rounded,
    'trending_up': Icons.trending_up_rounded,
    'redeem': Icons.redeem_rounded,
  };

  /// Mengembalikan [IconData] dari key ikon; fallback ke ikon dompet default.
  static IconData resolve(String? iconKey) {
    if (iconKey == null) return Icons.account_balance_wallet_rounded;
    return _map[iconKey] ?? Icons.account_balance_wallet_rounded;
  }
}
