import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDatabase _appDatabase;

  CategoryRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await _appDatabase.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
