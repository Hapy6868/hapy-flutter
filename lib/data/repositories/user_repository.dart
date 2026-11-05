import '../../models/models.dart';
import '../app_database.dart';

class UserRepository {
  UserRepository(this._db);
  final AppDatabase _db;

  Future<List<AppUser>> all() async =>
      (await _db.db.query('users', orderBy: 'id')).map(AppUser.fromMap).toList();

  Future<AppUser?> byId(int id) async {
    final rows = await _db.db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  /// Tạo bé mới kèm 2 từ điển mặc định (từ vựng + câu).
  Future<AppUser> create({required String name, required String emoji, required int colorValue}) async {
    final user = AppUser(name: name, emoji: emoji, colorValue: colorValue);
    user.id = await _db.save('users', null, user.toMap());
    await _db.save('lexicons', null,
        Lexicon(userId: user.id!, name: 'Từ vựng của bé', emoji: '📚', kind: EntryKind.word).toMap());
    await _db.save('lexicons', null,
        Lexicon(userId: user.id!, name: 'Câu giao tiếp', emoji: '💬', kind: EntryKind.sentence).toMap());
    return user;
  }

  Future<void> delete(int id) async {
    await _db.db.transaction((t) async {
      for (final table in ['entries', 'notes', 'reminders', 'lexicons']) {
        await t.delete(table, where: 'user_id = ?', whereArgs: [id]);
      }
      await t.delete('users', where: 'id = ?', whereArgs: [id]);
    });
  }
}
