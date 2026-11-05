import 'package:flutter/foundation.dart';

import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'app_session.dart';

const weekdayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

/// Mô tả giờ + kiểu lặp, ví dụ "19:00 • Hằng ngày".
String describeReminder(Reminder r) {
  final t = '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}';
  switch (r.repeat) {
    case RepeatKind.once:
      final p = r.date.split('-');
      final d = p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : r.date;
      return '$t • $d';
    case RepeatKind.daily:
      return '$t • Hằng ngày';
    case RepeatKind.weekly:
      return '$t • Mỗi ${weekdayNames[r.weekday.clamp(1, 7).toInt() - 1]}';
  }
}

class RemindersViewModel extends ChangeNotifier {
  RemindersViewModel(this._session, this._reminders, this._scheduler);

  final AppSession _session;
  final ReminderRepository _reminders;
  final ReminderScheduler _scheduler;

  List<Reminder> items = [];

  Future<void> load() async {
    final u = _session.user;
    items = u == null ? [] : await _reminders.forUser(u.id!);
    notifyListeners();
  }

  Future<void> toggle(Reminder r) async {
    r.enabled = !r.enabled;
    await _reminders.save(r);
    await _scheduler.schedule(r);
    await load();
  }

  Future<void> remove(Reminder r) async {
    await _scheduler.cancel(r.id!);
    await _reminders.delete(r.id!);
    await load();
  }
}
