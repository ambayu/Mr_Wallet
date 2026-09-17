import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final AppDatabase _appDatabase;

  WalletRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<WalletModel>> getAllWallets() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      orderBy: 'is_default DESC, name ASC',
    );
    return maps.map((e) => WalletModel.fromMap(e)).toList();
  }

  Future<WalletModel?> getWalletById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    }
    return null;
  }

  Future<WalletModel?> getDefaultWallet() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'is_default = 1',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    }
    final all = await getAllWallets();
    return all.isNotEmpty ? all.first : null;
  }

  Future<void> insertWallet(WalletModel wallet) async {
    final db = await _appDatabase.database;
    await db.insert(
      'wallets',
      wallet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final db = await _appDatabase.database;
    await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<void> deleteWallet(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalBalance() async {
    final db = await _appDatabase.database;
    final result = await db.rawQuery('SELECT SUM(balance) as total FROM wallets');
    final total = result.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }
}
