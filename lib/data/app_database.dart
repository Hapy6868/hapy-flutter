import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Mở SQLite và tạo bảng. Các repository dùng chung một AppDatabase.
/// Tên file `hapy_v2.db` khác bản v1 (`hapy.db`) nên không đụng dữ liệu cũ.
class AppDatabase {
  AppDatabase(this.db);

  final Database db;

  static Future<AppDatabase> open({String fileName = 'hapy_v2.db'}) async {
    final path = p.join(await getDatabasesPath(), fileName);
    final db = await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return AppDatabase(db);
  }

  static Future<void> _onCreate(Database d, int version) async {
    await d.execute('''CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, emoji TEXT, color INTEGER,
      created_at TEXT, synced INTEGER DEFAULT 0)''');
    await d.execute('''CREATE TABLE lexicons(
      id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, name TEXT, emoji TEXT,
      kind INTEGER, source_lang TEXT, target_lang TEXT, synced INTEGER DEFAULT 0)''');
    await d.execute('''CREATE TABLE entries(
      id INTEGER PRIMARY KEY AUTOINCREMENT, lexicon_id INTEGER NOT NULL, user_id INTEGER NOT NULL,
      text TEXT, phonetic TEXT, meaning TEXT, example TEXT, auto_phonetic TEXT, auto_meaning TEXT,
      phonetic_edited INTEGER DEFAULT 0, meaning_edited INTEGER DEFAULT 0, image TEXT,
      study_date TEXT, created_at TEXT, synced INTEGER DEFAULT 0,
      review_count INTEGER DEFAULT 0, last_reviewed TEXT, hard INTEGER DEFAULT 0)''');
    await d.execute('CREATE INDEX idx_entries_lex_date ON entries(lexicon_id, study_date)');
    await d.execute('''CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, study_date TEXT, emoji TEXT,
      content TEXT, synced INTEGER DEFAULT 0)''');
    await d.execute('''CREATE TABLE reminders(
      id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT, emoji TEXT,
      hour INTEGER, minute INTEGER, repeat INTEGER, weekday INTEGER, date TEXT,
      enabled INTEGER DEFAULT 1, synced INTEGER DEFAULT 0)''');
    await d.execute('CREATE TABLE settings(k TEXT PRIMARY KEY, v TEXT)');
  }

  static Future<void> _onUpgrade(Database d, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await d.execute('ALTER TABLE entries ADD COLUMN review_count INTEGER DEFAULT 0');
      await d.execute('ALTER TABLE entries ADD COLUMN last_reviewed TEXT');
      await d.execute('ALTER TABLE entries ADD COLUMN hard INTEGER DEFAULT 0');
    }
  }

  /// Thêm mới (id == null) hoặc cập nhật; luôn đánh dấu "chưa đồng bộ". Trả về id.
  Future<int> save(String table, int? id, Map<String, Object?> values) async {
    final v = Map<String, Object?>.of(values)
      ..remove('id')
      ..['synced'] = 0;
    if (id == null) return db.insert(table, v);
    await db.update(table, v, where: 'id = ?', whereArgs: [id]);
    return id;
  }
}
