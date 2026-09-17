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
          version: 1,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
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
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
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

      // Seed Default Categories
      final categories = [
        {'id': 'c_food', 'name': 'Makanan & Kopi', 'type': 'EXPENSE', 'icon': 'restaurant', 'color': '#FFF0B3'},
        {'id': 'c_shop', 'name': 'Belanja', 'type': 'EXPENSE', 'icon': 'shopping_bag', 'color': '#FFBEE3'},
        {'id': 'c_trans', 'name': 'Transportasi', 'type': 'EXPENSE', 'icon': 'directions_car', 'color': '#BFF2A5'},
        {'id': 'c_bill', 'name': 'Tagihan & Listrik', 'type': 'EXPENSE', 'icon': 'receipt_long', 'color': '#A594F9'},
        {'id': 'c_lost', 'name': 'Uang Hilang / Selisih', 'type': 'ADJUSTMENT', 'icon': 'help_outline', 'color': '#FF8A8A'},
        {'id': 'c_admin', 'name': 'Biaya Admin Bank', 'type': 'EXPENSE', 'icon': 'account_balance', 'color': '#E0E0E0'},
        {'id': 'c_salary', 'name': 'Gaji & Pendapatan', 'type': 'INCOME', 'icon': 'attach_money', 'color': '#BFF2A5'},
        {'id': 'c_transfer', 'name': 'Transfer Saldo', 'type': 'TRANSFER', 'icon': 'sync_alt', 'color': '#C4D7FF'},
      ];

      for (final cat in categories) {
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
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
