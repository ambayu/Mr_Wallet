import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/task_model.dart';

class TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        w.name AS wallet_name
      FROM tasks t
      LEFT JOIN wallets w ON t.wallet_id = w.id
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
        w.name AS wallet_name
      FROM tasks t
      LEFT JOIN wallets w ON t.wallet_id = w.id
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

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    final db = await _appDatabase.database;
    await db.update(
      'tasks',
      {'status': isCompleted ? 'COMPLETED' : 'PENDING'},
      where: 'id = ?',
      whereArgs: [id],
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
}
