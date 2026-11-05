import '../../models/models.dart';
import '../app_database.dart';

class EntryRepository {
  EntryRepository(this._db);
  final AppDatabase _db;

  /// [date] dạng yyyy-MM-dd; null = lấy tất cả các ngày.
  Future<List<VocabEntry>> list(int lexiconId, {String? date}) async {
    final rows = await _db.db.query(
      'entries',
      where: date == null ? 'lexicon_id = ?' : 'lexicon_id = ? AND study_date = ?',
      whereArgs: date == null ? [lexiconId] : [lexiconId, date],
      orderBy: 'id DESC',
    );
    return rows.map(VocabEntry.fromMap).toList();
  }

  Future<VocabEntry> save(VocabEntry e) async {
    e.id = await _db.save('entries', e.id, e.toMap());
    return e;
  }

  Future<void> delete(int id) => _db.db.delete('entries', where: 'id = ?', whereArgs: [id]);

  /// Tìm nghĩa mà chính bé này từng lưu cho cùng từ/câu (không phân biệt hoa thường).
  Future<VocabEntry?> findUserEntry(int userId, String text, {int? exceptId}) async {
    final rows = await _db.db.rawQuery(
      "SELECT * FROM entries WHERE user_id = ? AND text = ? COLLATE NOCASE AND id <> ? AND meaning <> '' "
      'ORDER BY id DESC LIMIT 1',
      [userId, text.trim(), exceptId ?? 0],
    );
    return rows.isEmpty ? null : VocabEntry.fromMap(rows.first);
  }

  /// Lấy các từ/câu của một bé để ôn tập.
  /// [lexiconId] null = mọi từ điển; [sinceDate] (yyyy-MM-dd) null = mọi ngày.
  Future<List<VocabEntry>> forReview(int userId, {int? lexiconId, String? sinceDate}) async {
    final where = StringBuffer('user_id = ?');
    final args = <Object?>[userId];
    if (lexiconId != null) {
      where.write(' AND lexicon_id = ?');
      args.add(lexiconId);
    }
    if (sinceDate != null) {
      where.write(' AND study_date >= ?');
      args.add(sinceDate);
    }
    final rows = await _db.db.query('entries', where: where.toString(), whereArgs: args);
    return rows.map(VocabEntry.fromMap).toList();
  }

  /// Ghi kết quả một lần ôn: nhớ → bỏ nhãn "khó"; chưa nhớ → gắn nhãn "khó".
  Future<void> recordReview(int id, bool remembered) => _db.db.rawUpdate(
        'UPDATE entries SET review_count = review_count + 1, last_reviewed = ?, hard = ?, synced = 0 WHERE id = ?',
        [DateTime.now().toIso8601String(), remembered ? 0 : 1, id],
      );
}
