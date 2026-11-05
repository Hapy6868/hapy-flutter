import '../../models/models.dart';
import '../app_database.dart';

class ReminderRepository {
  ReminderRepository(this._db);
  final AppDatabase _db;

  Future<List<Reminder>> forUser(int userId) async => (await _db.db.query(
        'reminders',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'hour, minute',
      ))
          .map(Reminder.fromMap)
          .toList();

  Future<Reminder> save(Reminder r) async {
    r.id = await _db.save('reminders', r.id, r.toMap());
    return r;
  }

  Future<void> delete(int id) => _db.db.delete('reminders', where: 'id = ?', whereArgs: [id]);
}
