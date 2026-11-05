import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

/// Lưu cặp khoá–giá trị đơn giản (bé đang chọn, địa chỉ server...).
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<String?> get(String key) async {
    final rows = await _db.db.query('settings', where: 'k = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['v'] as String?;
  }

  Future<void> set(String key, String value) =>
      _db.db.insert('settings', {'k': key, 'v': value}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> remove(String key) => _db.db.delete('settings', where: 'k = ?', whereArgs: [key]);
}
