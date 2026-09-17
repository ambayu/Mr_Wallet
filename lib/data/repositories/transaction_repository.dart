import '../../core/database/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final AppDatabase _appDatabase;

  TransactionRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  // Query transactions with joined Wallet & Category details
  Future<List<TransactionModel>> getRecentTransactions({int limit = 20}) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        w1.name AS wallet_name,
        w2.name AS to_wallet_name,
        c.name AS category_name,
        c.icon AS category_icon,
        c.color AS category_color
      FROM transactions t
      LEFT JOIN wallets w1 ON t.wallet_id = w1.id
      LEFT JOIN wallets w2 ON t.to_wallet_id = w2.id
      LEFT JOIN categories c ON t.category_id = c.id
      ORDER BY t.transaction_date DESC, t.created_at DESC
      LIMIT ?
    ''', [limit]);

    return maps.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByWallet(String walletId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        w1.name AS wallet_name,
        w2.name AS to_wallet_name,
        c.name AS category_name,
        c.icon AS category_icon,
        c.color AS category_color
      FROM transactions t
      LEFT JOIN wallets w1 ON t.wallet_id = w1.id
      LEFT JOIN wallets w2 ON t.to_wallet_id = w2.id
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.wallet_id = ? OR t.to_wallet_id = ?
      ORDER BY t.transaction_date DESC
    ''', [walletId, walletId]);

    return maps.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // ACID Insert Transaction & Update Balances
  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      // 1. Insert transaction record
      await txn.insert('transactions', transaction.toMap());

      // 2. Mutate wallet balances atomically
      if (transaction.type == 'INCOME') {
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
      } else if (transaction.type == 'EXPENSE') {
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
      } else if (transaction.type == 'TRANSFER' && transaction.toWalletId != null) {
        // Deduct from source
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
        // Add to destination
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.toWalletId],
        );
      } else if (transaction.type == 'ADJUSTMENT') {
        // Direct set to actual balance snapshot if provided, or adjust by amount
        if (transaction.actualBalanceSnapshot != null) {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = ? WHERE id = ?',
            [transaction.actualBalanceSnapshot, transaction.walletId],
          );
        } else {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = balance + ? WHERE id = ?',
            [transaction.amount, transaction.walletId],
          );
        }
      }
    });
  }

  // Reconciliation: Fitur Deteksi Uang Hilang / Selisih Saldo
  Future<TransactionModel> reconcileWalletBalance({
    required String transactionId,
    required String walletId,
    required double actualBalance,
    required String subType, // LOST_MONEY, ADMIN_FEE, INTEREST, REGULAR
    String? customNote,
  }) async {
    final db = await _appDatabase.database;

    return await db.transaction((txn) async {
      // 1. Get current system balance
      final walletMaps = await txn.query(
        'wallets',
        columns: ['balance', 'name'],
        where: 'id = ?',
        whereArgs: [walletId],
        limit: 1,
      );

      if (walletMaps.isEmpty) {
        throw Exception('Wallet not found with id $walletId');
      }

      final double systemBalance = (walletMaps.first['balance'] as num).toDouble();
      final String walletName = walletMaps.first['name'] as String;

      // Delta: delta = Actual - System
      final double delta = actualBalance - systemBalance;
      final double absDelta = delta.abs();

      String categoryId = 'c_lost';
      String desc;

      if (subType == 'LOST_MONEY') {
        categoryId = 'c_lost';
        desc = customNote?.isNotEmpty == true
            ? customNote!
            : 'Uang Hilang / Receh Jatuh ($walletName)';
      } else if (subType == 'ADMIN_FEE') {
        categoryId = 'c_admin';
        desc = customNote?.isNotEmpty == true
            ? customNote!
            : 'Biaya Admin Bank ($walletName)';
      } else if (subType == 'INTEREST') {
        categoryId = 'c_salary';
        desc = customNote?.isNotEmpty == true
            ? customNote!
            : 'Bunga Tabungan ($walletName)';
      } else {
        categoryId = 'c_lost';
        desc = customNote?.isNotEmpty == true
            ? customNote!
            : 'Penyesuaian Saldo Riil ($walletName)';
      }

      final transaction = TransactionModel(
        id: transactionId,
        walletId: walletId,
        categoryId: categoryId,
        type: 'ADJUSTMENT',
        amount: delta, // Can be positive or negative
        actualBalanceSnapshot: actualBalance,
        subType: subType,
        description: '$desc [Selisih: Rp ${absDelta.toStringAsFixed(0)}]',
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Save transaction
      await txn.insert('transactions', transaction.toMap());

      // Update wallet balance immediately to actual
      await txn.update(
        'wallets',
        {'balance': actualBalance},
        where: 'id = ?',
        whereArgs: [walletId],
      );

      return transaction;
    });
  }

  // Delete transaction and revert balance safely
  Future<void> deleteTransaction(TransactionModel transaction) async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      // Revert balances
      if (transaction.type == 'INCOME') {
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
      } else if (transaction.type == 'EXPENSE') {
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
      } else if (transaction.type == 'TRANSFER' && transaction.toWalletId != null) {
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.toWalletId],
        );
      } else if (transaction.type == 'ADJUSTMENT') {
        // Revert delta
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.walletId],
        );
      }

      await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    });
  }

  // Analytics helper methods
  Future<double> getMonthlySpending(DateTime month) async {
    final db = await _appDatabase.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'EXPENSE' AND transaction_date >= ? AND transaction_date <= ?
    ''', [start, end]);

    final total = result.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getMonthlyIncome(DateTime month) async {
    final db = await _appDatabase.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'INCOME' AND transaction_date >= ? AND transaction_date <= ?
    ''', [start, end]);

    final total = result.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getCategorySpending(DateTime month) async {
    final db = await _appDatabase.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.icon,
        c.color,
        SUM(t.amount) as total_amount,
        COUNT(t.id) as count
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = 'EXPENSE' AND t.transaction_date >= ? AND t.transaction_date <= ?
      GROUP BY c.id, c.name, c.icon, c.color
      ORDER BY total_amount DESC
    ''', [start, end]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrend(int year) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> monthlyData = [];

    for (int m = 1; m <= 6; m++) {
      final start = DateTime(year, m, 1).toIso8601String();
      final end = DateTime(year, m + 1, 0, 23, 59, 59).toIso8601String();

      final res = await db.rawQuery('''
        SELECT 
          COALESCE(SUM(CASE WHEN type = 'EXPENSE' THEN amount ELSE 0 END), 0) as expense,
          COALESCE(SUM(CASE WHEN type = 'INCOME' THEN amount ELSE 0 END), 0) as income
        FROM transactions
        WHERE transaction_date >= ? AND transaction_date <= ?
      ''', [start, end]);

      monthlyData.add({
        'month': m,
        'expense': (res.first['expense'] as num?)?.toDouble() ?? 0.0,
        'income': (res.first['income'] as num?)?.toDouble() ?? 0.0,
      });
    }

    return monthlyData;
  }
}
