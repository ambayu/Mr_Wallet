import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/task_model.dart';
import '../models/transaction_model.dart';

class TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        w.name AS wallet_name,
        c.name AS category_name
      FROM tasks t
      LEFT JOIN wallets w ON t.wallet_id = w.id
      LEFT JOIN categories c ON t.category_id = c.id
      ORDER BY 
        CASE t.status WHEN 'PENDING' THEN 1 WHEN 'IN_PROGRESS' THEN 2 ELSE 3 END,
        t.due_date ASC
    ''');
    return maps.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<List<TaskModel>> getPendingTasks() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        w.name AS wallet_name,
        c.name AS category_name
      FROM tasks t
      LEFT JOIN wallets w ON t.wallet_id = w.id
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.status != 'COMPLETED'
      ORDER BY t.due_date ASC
    ''');
    return maps.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final db = await _appDatabase.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await _appDatabase.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eksekusi Finansial Atomik saat Task dicentang selesai:
  /// 1. Potong/Tambah saldo dompet
  /// 2. Buat record transaksi di tabel transactions
  /// 3. Update status task menjadi COMPLETED + completed_at + transaction_id
  /// 4. Jika berulang (WEEKLY / MONTHLY), buat task baru untuk periode berikutnya
  Future<void> executeTaskCompletion({
    required TaskModel task,
    required String walletId,
    double? customAmount,
  }) async {
    final db = await _appDatabase.database;
    final amount = customAmount ?? task.estimatedAmount ?? 0.0;
    final now = DateTime.now();

    await db.transaction((txn) async {
      String? txId;

      // 1. Jika memiliki nominal dan walletId valid, lakukan mutasi saldo & simpan transaksi
      if (amount > 0) {
        txId = 'tx_${const Uuid().v4().substring(0, 8)}';
        final txType = task.isIncome ? 'INCOME' : 'EXPENSE';

        final transaction = TransactionModel(
          id: txId,
          walletId: walletId,
          categoryId: task.categoryId,
          type: txType,
          amount: amount,
          description: task.title,
          transactionDate: now,
          createdAt: now,
        );

        await txn.insert('transactions', transaction.toMap());

        // Mutasi saldo dompet
        if (task.isIncome) {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = balance + ? WHERE id = ?',
            [amount, walletId],
          );
        } else {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = balance - ? WHERE id = ?',
            [amount, walletId],
          );
        }
      }

      // 2. Update task aktif menjadi COMPLETED
      await txn.update(
        'tasks',
        {
          'status': 'COMPLETED',
          'completed_at': now.toIso8601String(),
          'wallet_id': walletId,
          'transaction_id': txId,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // 3. Jika berulang, jadwalkan task baru untuk siklus berikutnya
      if (task.isRecurring) {
        DateTime nextDueDate;
        if (task.recurrence == 'WEEKLY') {
          nextDueDate = task.dueDate.add(const Duration(days: 7));
        } else {
          // MONTHLY: tambah 1 bulan secara aman
          final d = task.dueDate;
          int nextMonth = d.month + 1;
          int nextYear = d.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear += 1;
          }
          final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          final day = d.day > daysInNextMonth ? daysInNextMonth : d.day;
          nextDueDate = DateTime(nextYear, nextMonth, day, d.hour, d.minute);
        }

        final nextTask = TaskModel(
          id: 'tsk_${const Uuid().v4().substring(0, 8)}',
          title: task.title,
          description: task.description,
          priority: task.priority,
          status: 'PENDING',
          type: task.type,
          recurrence: task.recurrence,
          categoryId: task.categoryId,
          dueDate: nextDueDate,
          reminderAt: nextDueDate,
          estimatedAmount: task.estimatedAmount,
          walletId: walletId,
        );

        await txn.insert('tasks', nextTask.toMap());
      }
    });
  }

  /// Membatalkan penyelesaian task (revert balance & hapus transaksi otomatis)
  Future<void> revertTaskCompletion(TaskModel task) async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      // 1. Jika ada transaksi terkait, revert saldo dan hapus transaksi
      if (task.transactionId != null && task.walletId != null && (task.estimatedAmount ?? 0) > 0) {
        final amount = task.estimatedAmount!;
        if (task.isIncome) {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = balance - ? WHERE id = ?',
            [amount, task.walletId],
          );
        } else {
          await txn.rawUpdate(
            'UPDATE wallets SET balance = balance + ? WHERE id = ?',
            [amount, task.walletId],
          );
        }

        await txn.delete(
          'transactions',
          where: 'id = ?',
          whereArgs: [task.transactionId],
        );
      }

      // 2. Kembalikan status task menjadi PENDING
      await txn.update(
        'tasks',
        {
          'status': 'PENDING',
          'completed_at': null,
          'transaction_id': null,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );
    });
  }
}
