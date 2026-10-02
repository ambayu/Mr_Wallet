import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        'smartflow_ledger.db',
        options: OpenDatabaseOptions(
          version: 2,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final docDir = await getApplicationDocumentsDirectory();
      final dbFolder = Directory(join(docDir.path, 'SmartFlow'));
      if (!dbFolder.existsSync()) {
        dbFolder.createSync(recursive: true);
      }
      path = join(dbFolder.path, 'smartflow_ledger.db');
    } else {
      final databasesPath = await getDatabasesPath();
      path = join(databasesPath, 'smartflow_ledger.db');
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    if (!kIsWeb) {
      // Enforce Foreign Key constraints
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // 1. Wallets table
      await txn.execute('''
        CREATE TABLE wallets (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          balance REAL NOT NULL DEFAULT 0.0,
          icon TEXT NOT NULL,
          color TEXT NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      // 2. Categories table
      await txn.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon TEXT NOT NULL,
          color TEXT NOT NULL
        )
      ''');

      // 3. Transactions table
      await txn.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          to_wallet_id TEXT,
          category_id TEXT,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          actual_balance_snapshot REAL,
          sub_type TEXT NOT NULL DEFAULT 'REGULAR',
          description TEXT NOT NULL DEFAULT '',
          receipt_image_path TEXT,
          transaction_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
          FOREIGN KEY (to_wallet_id) REFERENCES wallets (id) ON DELETE SET NULL,
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
        )
      ''');

      // 4. Tasks table
      await txn.execute('''
        CREATE TABLE tasks (
          id TEXT PRIMARY KEY,
          transaction_id TEXT,
          title TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          priority TEXT NOT NULL DEFAULT 'MEDIUM',
          status TEXT NOT NULL DEFAULT 'PENDING',
          due_date TEXT NOT NULL,
          reminder_at TEXT,
          estimated_amount REAL,
          wallet_id TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE SET NULL,
          FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE SET NULL
        )
      ''');

      // Indexing for high-performance querying
      await txn.execute('CREATE INDEX idx_trans_date ON transactions (transaction_date)');
      await txn.execute('CREATE INDEX idx_trans_wallet ON transactions (wallet_id)');
      await txn.execute('CREATE INDEX idx_tasks_due ON tasks (due_date)');

      // 5. Savings Goals table (Pencapaian / Target Tabungan)
      await _createSavingsGoalsTable(txn);

      // Seed Initial Wallets
      final now = DateTime.now().toIso8601String();
      await txn.insert('wallets', {
        'id': 'w_cash',
        'name': 'Dompet Tunai',
        'type': 'CASH',
        'balance': 350000.0,
        'icon': 'payments',
        'color': '#FFF0B3', // Yellow Pastel
        'is_default': 1,
        'created_at': now,
      });

      await txn.insert('wallets', {
        'id': 'w_bca',
        'name': 'ATM BCA',
        'type': 'BANK',
        'balance': 2500000.0,
        'icon': 'account_balance',
        'color': '#BFF2A5', // Mint Lime Green
        'is_default': 0,
        'created_at': now,
      });

      await txn.insert('wallets', {
        'id': 'w_mandiri',
        'name': 'ATM Mandiri',
        'type': 'BANK',
        'balance': 1200000.0,
        'icon': 'credit_card',
        'color': '#FFBEE3', // Pink
        'is_default': 0,
        'created_at': now,
      });

      await txn.insert('wallets', {
        'id': 'w_gopay',
        'name': 'GoPay / E-Wallet',
        'type': 'EWALLET',
        'balance': 150000.0,
        'icon': 'phone_android',
        'color': '#A594F9', // Lavender
        'is_default': 0,
        'created_at': now,
      });

      // Seed Default Categories (Katalog Kategori Lengkap)
      for (final cat in defaultCategoriesList) {
        await txn.insert('categories', cat);
      }

      // Seed Initial Sample Transactions
      await txn.insert('transactions', {
        'id': 'tx_1',
        'wallet_id': 'w_cash',
        'category_id': 'c_food',
        'type': 'EXPENSE',
        'amount': 25000.0,
        'sub_type': 'REGULAR',
        'description': 'Kopi Susu & Sarapan',
        'transaction_date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'created_at': now,
      });

      await txn.insert('transactions', {
        'id': 'tx_2',
        'wallet_id': 'w_bca',
        'category_id': 'c_shop',
        'type': 'EXPENSE',
        'amount': 150000.0,
        'sub_type': 'REGULAR',
        'description': 'Belanja Bulanan Supermarket',
        'transaction_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'created_at': now,
      });

      // Seed Initial Sample Tasks
      await txn.insert('tasks', {
        'id': 'tsk_1',
        'title': 'Bayar Tagihan Listrik PLN',
        'description': 'Bayar via ATM Mandiri sebelum tanggal 20',
        'priority': 'HIGH',
        'status': 'PENDING',
        'due_date': DateTime.now().add(const Duration(days: 1, hours: 4)).toIso8601String(),
        'estimated_amount': 250000.0,
        'wallet_id': 'w_mandiri',
        'created_at': now,
      });

      await txn.insert('tasks', {
        'id': 'tsk_2',
        'title': 'Servis Motor & Ganti Oli',
        'description': 'Bawa ke bengkel resmi',
        'priority': 'MEDIUM',
        'status': 'PENDING',
        'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'estimated_amount': 120000.0,
        'wallet_id': 'w_cash',
        'created_at': now,
      });

      // Seed Initial Savings Goals (Pencapaian)
      final savingsGoals = [
        {
          'id': 'sg_japan',
          'name': 'Liburan ke Jepang',
          'target_amount': 15000000.0,
          'saved_amount': 8000000.0,
          'deadline': null,
          'icon': 'flight_takeoff',
          'color': '#D6F0FF',
          'created_at': now,
        },
        {
          'id': 'sg_laptop',
          'name': 'Beli Laptop',
          'target_amount': 12000000.0,
          'saved_amount': 2500000.0,
          'deadline': null,
          'icon': 'laptop_mac',
          'color': '#D6F0FF',
          'created_at': now,
        },
        {
          'id': 'sg_emergency',
          'name': 'Dana Darurat',
          'target_amount': 10000000.0,
          'saved_amount': 2000000.0,
          'deadline': null,
          'icon': 'shield',
          'color': '#D6F0FF',
          'created_at': now,
        },
      ];

      for (final goal in savingsGoals) {
        await txn.insert('savings_goals', goal);
      }
    });
  }

  /// Membuat tabel savings_goals (dipakai onCreate & onUpgrade).
  Future<void> _createSavingsGoalsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL DEFAULT 0.0,
        saved_amount REAL NOT NULL DEFAULT 0.0,
        deadline TEXT,
        icon TEXT NOT NULL DEFAULT 'savings',
        color TEXT NOT NULL DEFAULT '#D6F0FF',
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Migrasi skema dari versi lama ke versi baru.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSavingsGoalsTable(db);

      // Seed default goals hanya jika tabel masih kosong (upgrade dari v1)
      final countResult =
          await db.rawQuery('SELECT COUNT(*) AS c FROM savings_goals');
      final existing = (countResult.first['c'] as num?)?.toInt() ?? 0;
      if (existing == 0) {
        final now = DateTime.now().toIso8601String();
        final savingsGoals = [
          {
            'id': 'sg_japan',
            'name': 'Liburan ke Jepang',
            'target_amount': 15000000.0,
            'saved_amount': 8000000.0,
            'deadline': null,
            'icon': 'flight_takeoff',
            'color': '#D6F0FF',
            'created_at': now,
          },
          {
            'id': 'sg_laptop',
            'name': 'Beli Laptop',
            'target_amount': 12000000.0,
            'saved_amount': 2500000.0,
            'deadline': null,
            'icon': 'laptop_mac',
            'color': '#D6F0FF',
            'created_at': now,
          },
          {
            'id': 'sg_emergency',
            'name': 'Dana Darurat',
            'target_amount': 10000000.0,
            'saved_amount': 2000000.0,
            'deadline': null,
            'icon': 'shield',
            'color': '#D6F0FF',
            'created_at': now,
          },
        ];
        for (final goal in savingsGoals) {
          await db.insert('savings_goals', goal);
        }
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Katalog Kategori Default Lengkap (Sederhana 1 Kata & Terstruktur Berdasarkan Prioritas).
  static const List<Map<String, dynamic>> defaultCategoriesList = [
    // --- 1. Kebutuhan Pokok & Harian (Prioritas Utama) ---
    {'id': 'c_food', 'name': 'Makan', 'type': 'EXPENSE', 'icon': 'restaurant', 'color': '#FFF0B3'},
    {'id': 'c_drink', 'name': 'Minum', 'type': 'EXPENSE', 'icon': 'local_cafe', 'color': '#FFDEB5'},
    {'id': 'c_snack', 'name': 'Camilan', 'type': 'EXPENSE', 'icon': 'cookie', 'color': '#FFF0B3'},
    {'id': 'c_shop', 'name': 'Belanja', 'type': 'EXPENSE', 'icon': 'shopping_bag', 'color': '#FFBEE3'},
    {'id': 'c_veg', 'name': 'Sayur', 'type': 'EXPENSE', 'icon': 'eco', 'color': '#CEF8BA'},
    {'id': 'c_fruit', 'name': 'Buah', 'type': 'EXPENSE', 'icon': 'apple', 'color': '#FFCCD5'},
    {'id': 'c_clothes', 'name': 'Baju', 'type': 'EXPENSE', 'icon': 'checkroom', 'color': '#E4DBFA'},

    // --- 2. Kendaraan & Transportasi ---
    {'id': 'c_gas', 'name': 'Bensin', 'type': 'EXPENSE', 'icon': 'local_gas_station', 'color': '#BFF2A5'},
    {'id': 'c_motor', 'name': 'Motor', 'type': 'EXPENSE', 'icon': 'two_wheeler', 'color': '#D2EEFC'},
    {'id': 'c_car', 'name': 'Mobil', 'type': 'EXPENSE', 'icon': 'directions_car', 'color': '#D2EEFC'},
    {'id': 'c_parking', 'name': 'Parkir', 'type': 'EXPENSE', 'icon': 'local_parking', 'color': '#E0E0E0'},
    {'id': 'c_trans', 'name': 'Transport', 'type': 'EXPENSE', 'icon': 'directions_bus', 'color': '#BFF2A5'},
    {'id': 'c_travel', 'name': 'Liburan', 'type': 'EXPENSE', 'icon': 'flight', 'color': '#FFDEB5'},

    // --- 3. Tagihan & Tempat Tinggal ---
    {'id': 'c_phone', 'name': 'Pulsa', 'type': 'EXPENSE', 'icon': 'phone_android', 'color': '#D2EEFC'},
    {'id': 'c_wifi', 'name': 'WiFi', 'type': 'EXPENSE', 'icon': 'wifi', 'color': '#D2EEFC'},
    {'id': 'c_bill', 'name': 'Listrik', 'type': 'EXPENSE', 'icon': 'receipt_long', 'color': '#A594F9'},
    {'id': 'c_water', 'name': 'Air', 'type': 'EXPENSE', 'icon': 'water_drop', 'color': '#D2EEFC'},
    {'id': 'c_housing', 'name': 'Kos', 'type': 'EXPENSE', 'icon': 'apartment', 'color': '#D2EEFC'},
    {'id': 'c_home', 'name': 'Rumah', 'type': 'EXPENSE', 'icon': 'home', 'color': '#FFDEB5'},
    {'id': 'c_laundry', 'name': 'Laundry', 'type': 'EXPENSE', 'icon': 'local_laundry_service', 'color': '#E4DBFA'},
    {'id': 'c_sub', 'name': 'Langganan', 'type': 'EXPENSE', 'icon': 'subscriptions', 'color': '#FFCCD5'},
    {'id': 'c_tax', 'name': 'Pajak', 'type': 'EXPENSE', 'icon': 'request_quote', 'color': '#E0E0E0'},
    {'id': 'c_ins', 'name': 'Asuransi', 'type': 'EXPENSE', 'icon': 'shield', 'color': '#D2EEFC'},
    {'id': 'c_repair', 'name': 'Servis', 'type': 'EXPENSE', 'icon': 'build', 'color': '#E0E0E0'},

    // --- 4. Kesehatan & Edukasi ---
    {'id': 'c_health', 'name': 'Kesehatan', 'type': 'EXPENSE', 'icon': 'local_hospital', 'color': '#FFCCD5'},
    {'id': 'c_medicine', 'name': 'Obat', 'type': 'EXPENSE', 'icon': 'medication', 'color': '#FFCCD5'},
    {'id': 'c_skincare', 'name': 'Skincare', 'type': 'EXPENSE', 'icon': 'shower', 'color': '#FFDEB5'},
    {'id': 'c_beauty', 'name': 'Cantik', 'type': 'EXPENSE', 'icon': 'spa', 'color': '#FFCCD5'},
    {'id': 'c_edu', 'name': 'Sekolah', 'type': 'EXPENSE', 'icon': 'school', 'color': '#D2EEFC'},
    {'id': 'c_book', 'name': 'Buku', 'type': 'EXPENSE', 'icon': 'menu_book', 'color': '#CEF8BA'},
    {'id': 'c_kids', 'name': 'Anak', 'type': 'EXPENSE', 'icon': 'child_care', 'color': '#E4DBFA'},

    // --- 5. Hiburan & Sosial ---
    {'id': 'c_social', 'name': 'Nongkrong', 'type': 'EXPENSE', 'icon': 'groups', 'color': '#E4DBFA'},
    {'id': 'c_game', 'name': 'Game', 'type': 'EXPENSE', 'icon': 'sports_esports', 'color': '#FFDEB5'},
    {'id': 'c_sport', 'name': 'Olahraga', 'type': 'EXPENSE', 'icon': 'fitness_center', 'color': '#CEF8BA'},
    {'id': 'c_hobby', 'name': 'Hobi', 'type': 'EXPENSE', 'icon': 'palette', 'color': '#E4DBFA'},
    {'id': 'c_gift', 'name': 'Kado', 'type': 'EXPENSE', 'icon': 'card_giftcard', 'color': '#FFCCD5'},
    {'id': 'c_donation', 'name': 'Sedekah', 'type': 'EXPENSE', 'icon': 'volunteer_activism', 'color': '#CEF8BA'},
    {'id': 'c_smoke', 'name': 'Rokok', 'type': 'EXPENSE', 'icon': 'smoking_rooms', 'color': '#E0E0E0'},
    {'id': 'c_pet', 'name': 'Hewan', 'type': 'EXPENSE', 'icon': 'pets', 'color': '#FFF0B3'},
    {'id': 'c_device', 'name': 'Gadget', 'type': 'EXPENSE', 'icon': 'devices', 'color': '#D2EEFC'},
    {'id': 'c_lottery', 'name': 'Lotre', 'type': 'EXPENSE', 'icon': 'casino', 'color': '#FFF0B3'},

    // --- 6. Finansial & Pendapatan ---
    {'id': 'c_salary', 'name': 'Gaji', 'type': 'INCOME', 'icon': 'attach_money', 'color': '#BFF2A5'},
    {'id': 'c_bonus', 'name': 'Bonus', 'type': 'INCOME', 'icon': 'redeem', 'color': '#BFF2A5'},
    {'id': 'c_biz', 'name': 'Usaha', 'type': 'INCOME', 'icon': 'storefront', 'color': '#FFF0B3'},
    {'id': 'c_invest', 'name': 'Investasi', 'type': 'INCOME', 'icon': 'trending_up', 'color': '#BFF2A5'},
    {'id': 'c_debt', 'name': 'Cicilan', 'type': 'EXPENSE', 'icon': 'credit_card', 'color': '#FF8A8A'},
    {'id': 'c_transfer', 'name': 'Transfer', 'type': 'TRANSFER', 'icon': 'sync_alt', 'color': '#C4D7FF'},
    {'id': 'c_lost', 'name': 'Selisih', 'type': 'ADJUSTMENT', 'icon': 'help_outline', 'color': '#FF8A8A'},
    {'id': 'c_admin', 'name': 'Admin', 'type': 'EXPENSE', 'icon': 'account_balance', 'color': '#E0E0E0'},
  ];
}
