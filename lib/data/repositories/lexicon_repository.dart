import '../../models/models.dart';
import '../app_database.dart';

class LexiconRepository {
  LexiconRepository(this._db);
  final AppDatabase _db;

  Future<List<Lexicon>> forUser(int userId) async => (await _db.db
          .query('lexicons', where: 'user_id = ?', whereArgs: [userId], orderBy: 'id'))
      .map(Lexicon.fromMap)
      .toList();

  Future<Lexicon> save(Lexicon l) async {
    l.id = await _db.save('lexicons', l.id, l.toMap());
    return l;
  }

  /// Xoá từ điển cùng toàn bộ từ/câu bên trong.
  Future<void> delete(int id) async {
    await _db.db.transaction((t) async {
      await t.delete('entries', where: 'lexicon_id = ?', whereArgs: [id]);
      await t.delete('lexicons', where: 'id = ?', whereArgs: [id]);
    });
  }
}
