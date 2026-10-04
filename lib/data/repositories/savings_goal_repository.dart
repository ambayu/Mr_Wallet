import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepository {
  final AppDatabase _appDatabase;

  SavingsGoalRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<SavingsGoalModel>> getAllGoals() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        sg.*,
        w.name AS wallet_name,
        w.icon AS wallet_icon,
        w.balance AS current_wallet_balance
      FROM savings_goals sg
      LEFT JOIN wallets w ON sg.wallet_id = w.id
      ORDER BY sg.created_at ASC
    ''');
    return maps.map((e) => SavingsGoalModel.fromMap(e)).toList();
  }

  Future<void> insertGoal(SavingsGoalModel goal) async {
    final db = await _appDatabase.database;
    await db.insert(
      'savings_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    final db = await _appDatabase.database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Menyelesaikan target pencapaian: Memotong saldo dompet acuan secara ACID dan mencatat transaksi pengeluaran.
  Future<bool> completeGoalWithFinancialDeduction({
    required SavingsGoalModel goal,
    required String walletId,
  }) async {
    final db = await _appDatabase.database;

    return await db.transaction((txn) async {
      // 1. Cek saldo dompet
      final walletMaps = await txn.query(
        'wallets',
        columns: ['balance', 'name'],
        where: 'id = ?',
        whereArgs: [walletId],
        limit: 1,
      );

      if (walletMaps.isEmpty) {
        throw Exception('Dompet tidak ditemukan!');
      }

      final double currentBalance = (walletMaps.first['balance'] as num).toDouble();
      final double deductAmount = goal.targetAmount;

      // 2. Validasi apakah saldo cukup
      if (currentBalance < deductAmount) {
        return false; // Saldo tidak cukup
      }

      // 3. Potong saldo dompet
      await txn.rawUpdate(
        'UPDATE wallets SET balance = balance - ? WHERE id = ?',
        [deductAmount, walletId],
      );

      // 4. Catat transaksi pengeluaran realisasi pencapaian
      final now = DateTime.now().toIso8601String();
      await txn.insert('transactions', {
        'id': 'tx_goal_${DateTime.now().millisecondsSinceEpoch}',
        'wallet_id': walletId,
        'category_id': 'c_travel', // Kategori default atau goal
        'type': 'EXPENSE',
        'amount': deductAmount,
        'description': 'Realisasi Pencapaian: ${goal.name}',
        'transaction_date': now,
        'created_at': now,
      });

      // 5. Update goal menjadi selesai
      await txn.rawUpdate(
        'UPDATE savings_goals SET is_completed = 1, completed_at = ?, saved_amount = ? WHERE id = ?',
        [now, deductAmount, goal.id],
      );

      return true;
    });
  }

  /// Membatalkan status selesai pencapaian dan mengembalikan saldo dompet
  Future<void> revertGoalCompletion({
    required SavingsGoalModel goal,
  }) async {
    final db = await _appDatabase.database;
    final walletId = goal.walletId;

    await db.transaction((txn) async {
      if (walletId != null) {
        // Kembalikan saldo dompet
        await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [goal.targetAmount, walletId],
        );

        // Hapus transaksi realisasi terkait
        await txn.delete(
          'transactions',
          where: "description = ?",
          whereArgs: ['Realisasi Pencapaian: ${goal.name}'],
        );
      }

      // Update status kembali aktif
      await txn.rawUpdate(
        'UPDATE savings_goals SET is_completed = 0, completed_at = NULL WHERE id = ?',
        [goal.id],
      );
    });
  }

  /// Menambah dana terkumpul secara atomik (tanpa menurunkan di bawah 0).
  Future<void> addFunds(String id, double amount) async {
    final db = await _appDatabase.database;
    await db.rawUpdate(
      'UPDATE savings_goals SET saved_amount = MAX(0, saved_amount + ?) WHERE id = ?',
      [amount, id],
    );
  }
}
