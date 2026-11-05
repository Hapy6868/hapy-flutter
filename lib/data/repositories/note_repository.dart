import '../../models/models.dart';
import '../app_database.dart';

class NoteRepository {
  NoteRepository(this._db);
  final AppDatabase _db;

  Future<List<StudyNote>> forDay(int userId, String date) async => (await _db.db.query(
        'notes',
        where: 'user_id = ? AND study_date = ?',
        whereArgs: [userId, date],
        orderBy: 'id DESC',
      ))
          .map(StudyNote.fromMap)
          .toList();

  Future<StudyNote> save(StudyNote n) async {
    n.id = await _db.save('notes', n.id, n.toMap());
    return n;
  }

  Future<void> delete(int id) => _db.db.delete('notes', where: 'id = ?', whereArgs: [id]);
}
