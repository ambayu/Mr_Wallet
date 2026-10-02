import '../../data/models/category_model.dart';

/// Struktur representasi grup/seksi kategori di antarmuka.
class CategoryGroupSection {
  final String title;
  final List<CategoryModel> categories;

  const CategoryGroupSection({
    required this.title,
    required this.categories,
  });
}

/// Helper pengelompokan kategori terstruktur dengan urutan prioritas:
/// Yang paling penting dan sering digunakan berada di urutan paling atas.
class CategoryGroupHelper {
  CategoryGroupHelper._();

  /// Definisi pemetaan ID kategori default untuk tab Pengeluaran (EXPENSE).
  static const List<Map<String, dynamic>> _expenseGroupDefinitions = [
    {
      'title': 'Kebutuhan Harian',
      'ids': [
        'c_food',
        'c_drink',
        'c_snack',
        'c_shop',
        'c_veg',
        'c_fruit',
        'c_clothes',
      ],
    },
    {
      'title': 'Kendaraan & Transport',
      'ids': [
        'c_gas',
        'c_motor',
        'c_car',
        'c_parking',
        'c_trans',
        'c_travel',
      ],
    },
    {
      'title': 'Tagihan & Tempat Tinggal',
      'ids': [
        'c_phone',
        'c_wifi',
        'c_bill',
        'c_water',
        'c_housing',
        'c_home',
        'c_laundry',
        'c_sub',
        'c_tax',
        'c_ins',
        'c_repair',
      ],
    },
    {
      'title': 'Kesehatan & Edukasi',
      'ids': [
        'c_health',
        'c_medicine',
        'c_skincare',
        'c_beauty',
        'c_edu',
        'c_book',
        'c_kids',
      ],
    },
    {
      'title': 'Hiburan & Gaya Hidup',
      'ids': [
        'c_social',
        'c_game',
        'c_sport',
        'c_hobby',
        'c_gift',
        'c_donation',
        'c_smoke',
        'c_pet',
        'c_device',
        'c_lottery',
      ],
    },
    {
      'title': 'Finansial & Lainnya',
      'ids': [
        'c_debt',
        'c_admin',
        'c_lost',
        'c_transfer',
        'c_salary',
        'c_bonus',
        'c_biz',
        'c_invest',
      ],
    },
  ];

  /// Definisi pemetaan ID kategori default untuk tab Pemasukan (INCOME).
  /// Menempatkan Finansial & Sumber Pendapatan di paling atas.
  static const List<Map<String, dynamic>> _incomeGroupDefinitions = [
    {
      'title': 'Sumber Pendapatan Utama',
      'ids': [
        'c_salary',
        'c_bonus',
        'c_biz',
        'c_invest',
        'c_gift',
        'c_donation',
        'c_lost',
        'c_transfer',
      ],
    },
    {
      'title': 'Kebutuhan Harian & Jual/Refund',
      'ids': [
        'c_shop',
        'c_clothes',
        'c_food',
        'c_drink',
        'c_snack',
        'c_veg',
        'c_fruit',
      ],
    },
    {
      'title': 'Gaya Hidup & Barang',
      'ids': [
        'c_device',
        'c_hobby',
        'c_game',
        'c_sport',
        'c_lottery',
        'c_pet',
        'c_social',
        'c_smoke',
      ],
    },
    {
      'title': 'Tagihan, Properti & Transport',
      'ids': [
        'c_housing',
        'c_home',
        'c_car',
        'c_motor',
        'c_gas',
        'c_travel',
        'c_trans',
        'c_parking',
        'c_phone',
        'c_wifi',
        'c_bill',
        'c_water',
        'c_laundry',
        'c_sub',
        'c_tax',
        'c_ins',
        'c_repair',
      ],
    },
    {
      'title': 'Kesehatan & Edukasi',
      'ids': [
        'c_health',
        'c_medicine',
        'c_skincare',
        'c_beauty',
        'c_edu',
        'c_book',
        'c_kids',
      ],
    },
  ];

  /// Mengelompokkan daftar [CategoryModel] secara cerdas berdasarkan tab aktif:
  /// - Tab Pengeluaran: Kebutuhan harian & transportasi di atas.
  /// - Tab Pemasukan: Gaji, bonus, usaha, investasi di paling atas!
  static List<CategoryGroupSection> groupCategories(
    List<CategoryModel> allCategories, {
    String activeTab = 'EXPENSE',
  }) {
    if (allCategories.isEmpty) return [];

    final groupDefinitions = activeTab == 'INCOME'
        ? _incomeGroupDefinitions
        : _expenseGroupDefinitions;

    final Map<String, CategoryModel> categoryMap = {
      for (final cat in allCategories) cat.id: cat,
    };

    final Set<String> matchedIds = {};
    final List<CategoryGroupSection> sections = [];

    // Kelompokkan berdasarkan definisi terurut
    for (final def in groupDefinitions) {
      final title = def['title'] as String;
      final ids = def['ids'] as List<String>;
      final List<CategoryModel> matched = [];

      for (final id in ids) {
        if (categoryMap.containsKey(id)) {
          matched.add(categoryMap[id]!);
          matchedIds.add(id);
        }
      }

      if (matched.isNotEmpty) {
        sections.add(CategoryGroupSection(title: title, categories: matched));
      }
    }

    // Kategori kustom (yang dibuat user atau tidak ada di definisi default)
    final customCategories = allCategories
        .where((cat) => !matchedIds.contains(cat.id))
        .toList();

    if (customCategories.isNotEmpty) {
      sections.add(
        CategoryGroupSection(
          title: 'Kategori Lain',
          categories: customCategories,
        ),
      );
    }

    return sections;
  }
}
