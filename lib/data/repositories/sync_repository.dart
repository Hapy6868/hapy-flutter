import '../app_database.dart';

/// Gom các bản ghi chưa đồng bộ và đánh dấu sau khi gửi thành công.
class SyncRepository {
  SyncRepository(this._db);
  final AppDatabase _db;

  static const tables = ['users', 'lexicons', 'entries', 'notes', 'reminders'];

  Future<Map<String, List<Map<String, Object?>>>> unsynced() async {
    final result = <String, List<Map<String, Object?>>>{};
    for (final t in tables) {
      result[t] = await _db.db.query(t, where: 'synced = 0');
    }
    return result;
  }

  Future<void> markSynced(Map<String, List<Map<String, Object?>>> sent) async {
    await _db.db.transaction((tx) async {
      for (final entry in sent.entries) {
        for (final row in entry.value) {
          await tx.update(entry.key, {'synced': 1}, where: 'id = ?', whereArgs: [row['id']]);
        }
      }
    });
  }
}
