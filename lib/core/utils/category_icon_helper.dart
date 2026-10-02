import 'package:flutter/material.dart';

/// Item representasi ikon kategori untuk picker katalog.
class CategoryIconItem {
  final String key;
  final IconData icon;
  final String label;

  const CategoryIconItem({
    required this.key,
    required this.icon,
    required this.label,
  });
}

/// Pemetaan terpusat seluruh ikon kategori aplikasi SmartFlow / Mr. Wallet.
/// Berisi 45+ ikon kategori terkurasi (Material Icons Outlined & Rounded)
/// yang mencakup kebutuhan belanja harian, gaya hidup, tagihan, hingga pendapatan.
class CategoryIconHelper {
  CategoryIconHelper._();

  /// Katalog lengkap ikon yang bisa dipilih pengguna saat membuat/mengedit kategori.
  static const List<CategoryIconItem> catalog = [
    // --- Kebutuhan Pokok & Harian ---
    CategoryIconItem(key: 'restaurant', icon: Icons.restaurant_rounded, label: 'Makanan'),
    CategoryIconItem(key: 'fastfood', icon: Icons.fastfood_outlined, label: 'Makanan Cepat Saji'),
    CategoryIconItem(key: 'local_cafe', icon: Icons.local_cafe_outlined, label: 'Kopi & Minuman'),
    CategoryIconItem(key: 'local_drink', icon: Icons.local_drink_outlined, label: 'Air & Minuman'),
    CategoryIconItem(key: 'cookie', icon: Icons.cookie_outlined, label: 'Makanan Ringan'),
    CategoryIconItem(key: 'eco', icon: Icons.eco_outlined, label: 'Sayur-mayur'),
    CategoryIconItem(key: 'apple', icon: Icons.apple_outlined, label: 'Buah-buahan'),
    CategoryIconItem(key: 'smoking_rooms', icon: Icons.smoking_rooms_outlined, label: 'Rokok'),

    // --- Belanja & Lifestyle ---
    CategoryIconItem(key: 'shopping_bag', icon: Icons.shopping_bag_outlined, label: 'Belanja'),
    CategoryIconItem(key: 'shopping_cart', icon: Icons.shopping_cart_outlined, label: 'Supermarket'),
    CategoryIconItem(key: 'checkroom', icon: Icons.checkroom_outlined, label: 'Pakaian'),
    CategoryIconItem(key: 'spa', icon: Icons.spa_outlined, label: 'Kecantikan'),
    CategoryIconItem(key: 'content_cut', icon: Icons.content_cut_rounded, label: 'Potong Rambut'),
    CategoryIconItem(key: 'devices', icon: Icons.devices_outlined, label: 'Elektronik'),
    CategoryIconItem(key: 'card_giftcard', icon: Icons.card_giftcard_rounded, label: 'Hadiah'),

    // --- Transportasi & Perjalanan ---
    CategoryIconItem(key: 'directions_car', icon: Icons.directions_car_outlined, label: 'Mobil'),
    CategoryIconItem(key: 'two_wheeler', icon: Icons.two_wheeler_outlined, label: 'Motor'),
    CategoryIconItem(key: 'local_gas_station', icon: Icons.local_gas_station_outlined, label: 'Bensin'),
    CategoryIconItem(key: 'local_parking', icon: Icons.local_parking_rounded, label: 'Parkir'),
    CategoryIconItem(key: 'directions_bus', icon: Icons.directions_bus_outlined, label: 'Transportasi'),
    CategoryIconItem(key: 'flight', icon: Icons.flight_outlined, label: 'Bepergian / Tiket'),
    CategoryIconItem(key: 'commute', icon: Icons.commute_outlined, label: 'Komuter'),

    // --- Rumah & Tempat Tinggal ---
    CategoryIconItem(key: 'home', icon: Icons.home_outlined, label: 'Rumah'),
    CategoryIconItem(key: 'apartment', icon: Icons.apartment_outlined, label: 'Perumahan / Kos'),
    CategoryIconItem(key: 'chair', icon: Icons.chair_outlined, label: 'Perabotan'),
    CategoryIconItem(key: 'build', icon: Icons.build_outlined, label: 'Perbaikan'),
    CategoryIconItem(key: 'pets', icon: Icons.pets_outlined, label: 'Peliharaan'),
    CategoryIconItem(key: 'local_laundry_service', icon: Icons.local_laundry_service_outlined, label: 'Laundry'),
    CategoryIconItem(key: 'water_drop', icon: Icons.water_drop_outlined, label: 'Air PDAM'),

    // --- Komunikasi & Tagihan ---
    CategoryIconItem(key: 'phone_android', icon: Icons.phone_android_outlined, label: 'Telepon / Pulsa'),
    CategoryIconItem(key: 'wifi', icon: Icons.wifi_rounded, label: 'Internet / Wifi'),
    CategoryIconItem(key: 'receipt_long', icon: Icons.receipt_long_outlined, label: 'Tagihan'),
    CategoryIconItem(key: 'bolt', icon: Icons.bolt_rounded, label: 'Listrik PLN'),
    CategoryIconItem(key: 'subscriptions', icon: Icons.subscriptions_outlined, label: 'Langganan'),
    CategoryIconItem(key: 'request_quote', icon: Icons.request_quote_outlined, label: 'Pajak'),
    CategoryIconItem(key: 'shield', icon: Icons.shield_outlined, label: 'Asuransi'),

    // --- Hiburan & Sosial ---
    CategoryIconItem(key: 'sports_esports', icon: Icons.sports_esports_outlined, label: 'Hiburan / Game'),
    CategoryIconItem(key: 'movie', icon: Icons.movie_outlined, label: 'Bioskop / Film'),
    CategoryIconItem(key: 'fitness_center', icon: Icons.fitness_center_outlined, label: 'Olahraga'),
    CategoryIconItem(key: 'groups', icon: Icons.groups_outlined, label: 'Sosial / Nongkrong'),
    CategoryIconItem(key: 'casino', icon: Icons.casino_outlined, label: 'Lotre / Undian'),
    CategoryIconItem(key: 'volunteer_activism', icon: Icons.volunteer_activism_outlined, label: 'Donasi / Amal'),
    CategoryIconItem(key: 'palette', icon: Icons.palette_outlined, label: 'Hobi & Seni'),

    // --- Keluarga, Edukasi & Kesehatan ---
    CategoryIconItem(key: 'school', icon: Icons.school_outlined, label: 'Pendidikan'),
    CategoryIconItem(key: 'menu_book', icon: Icons.menu_book_outlined, label: 'Buku & Kursus'),
    CategoryIconItem(key: 'local_hospital', icon: Icons.local_hospital_outlined, label: 'Kesehatan'),
    CategoryIconItem(key: 'medication', icon: Icons.medication_outlined, label: 'Obat & Apotek'),
    CategoryIconItem(key: 'favorite', icon: Icons.favorite_outline_rounded, label: 'Medis'),
    CategoryIconItem(key: 'shower', icon: Icons.shower_outlined, label: 'Skincare & Mandi'),
    CategoryIconItem(key: 'child_care', icon: Icons.child_care_outlined, label: 'Anak-anak'),

    // --- Finansial, Kerja & Pemasukan ---
    CategoryIconItem(key: 'attach_money', icon: Icons.attach_money_rounded, label: 'Gaji'),
    CategoryIconItem(key: 'payments', icon: Icons.payments_outlined, label: 'Pendapatan'),
    CategoryIconItem(key: 'redeem', icon: Icons.redeem_rounded, label: 'Bonus & THR'),
    CategoryIconItem(key: 'work', icon: Icons.work_outline_rounded, label: 'Pekerjaan / Proyek'),
    CategoryIconItem(key: 'storefront', icon: Icons.storefront_outlined, label: 'Usaha / Bisnis'),
    CategoryIconItem(key: 'savings', icon: Icons.savings_outlined, label: 'Tabungan'),
    CategoryIconItem(key: 'trending_up', icon: Icons.trending_up_rounded, label: 'Investasi'),
    CategoryIconItem(key: 'credit_card', icon: Icons.credit_card_outlined, label: 'Cicilan & Utang'),
    CategoryIconItem(key: 'account_balance', icon: Icons.account_balance_outlined, label: 'Biaya Bank'),
    CategoryIconItem(key: 'sync_alt', icon: Icons.sync_alt_rounded, label: 'Transfer Saldo'),
    CategoryIconItem(key: 'help_outline', icon: Icons.help_outline_rounded, label: 'Selisih Saldo'),
  ];

  static final Map<String, IconData> _map = {
    for (final item in catalog) item.key: item.icon,
  };

  /// Mengembalikan [IconData] dari key ikon; fallback ke [Icons.category_outlined].
  static IconData resolve(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) return Icons.category_outlined;
    final lower = iconKey.toLowerCase().trim();
    if (_map.containsKey(lower)) return _map[lower]!;

    // Fallback alias kompatibilitas
    switch (lower) {
      case 'call':
        return Icons.phone_android_outlined;
      case 'food':
        return Icons.restaurant_rounded;
      case 'kopi':
      case 'coffee':
        return Icons.local_cafe_outlined;
      case 'drink':
        return Icons.local_drink_outlined;
      case 'shop':
      case 'belanja':
        return Icons.shopping_bag_outlined;
      case 'trans':
      case 'car':
        return Icons.directions_car_outlined;
      case 'motor':
      case 'gas':
        return Icons.two_wheeler_outlined;
      case 'game':
        return Icons.sports_esports_outlined;
      case 'bill':
      case 'tagihan':
        return Icons.receipt_long_outlined;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'salary':
      case 'gaji':
        return Icons.attach_money_rounded;
      case 'transfer':
        return Icons.sync_alt_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  /// Label default jika belum ada nama kategori kustom.
  static String getLabel(String? iconKey) {
    if (iconKey == null) return 'Kategori';
    for (final item in catalog) {
      if (item.key.toLowerCase() == iconKey.toLowerCase()) return item.label;
    }
    return 'Kategori';
  }
}
