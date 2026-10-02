import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepository {
  final AppDatabase _appDatabase;

  SavingsGoalRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<SavingsGoalModel>> getAllGoals() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      orderBy: 'created_at ASC',
    );
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

  /// Menambah dana terkumpul secara atomik (tanpa menurunkan di bawah 0).
  Future<void> addFunds(String id, double amount) async {
    final db = await _appDatabase.database;
    await db.rawUpdate(
      'UPDATE savings_goals SET saved_amount = MAX(0, saved_amount + ?) WHERE id = ?',
      [amount, id],
    );
  }
}
