import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDatabase _appDatabase;

  CategoryRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    if (maps.length < AppDatabase.defaultCategoriesList.length ||
        (maps.isNotEmpty && (maps.first['name'] as String).contains('&'))) {
      await ensureDefaultCategories();
      final reloaded = await db.query('categories');
      return reloaded.map((e) => CategoryModel.fromMap(e)).toList();
    }
    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  /// Memastikan kategori default lengkap tersedia di database dengan penamaan 1 kata terbaru.
  Future<void> ensureDefaultCategories() async {
    final db = await _appDatabase.database;
    final batch = db.batch();
    for (final cat in AppDatabase.defaultCategoriesList) {
      batch.insert(
        'categories',
        cat,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      // Sinkronkan nama kategori bawaan ke format 1 kata ringkas
      batch.update(
        'categories',
        {'name': cat['name'], 'icon': cat['icon'], 'color': cat['color']},
        where: 'id = ?',
        whereArgs: [cat['id']],
      );
    }
    await batch.commit(noResult: true);
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
