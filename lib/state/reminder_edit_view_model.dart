import 'package:flutter/material.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'app_session.dart';

class ReminderEditViewModel extends ChangeNotifier {
  ReminderEditViewModel(this._session, this._reminders, this._scheduler);

  final AppSession _session;
  final ReminderRepository _reminders;
  final ReminderScheduler _scheduler;

  static const emojiOptions = ['⏰', '📚', '✏️', '🎵', '🎨', '⭐', '🚀', '🌈'];

  final title = TextEditingController(text: 'Đến giờ học bài');
  String emoji = '⏰';
  TimeOfDay time = const TimeOfDay(hour: 19, minute: 0);
  RepeatKind repeat = RepeatKind.daily;
  DateTime date = dateOnly(DateTime.now());
  int weekday = DateTime.now().weekday;
  bool permissionDenied = false;

  void update(void Function() change) {
    change();
    notifyListeners();
  }

  /// Trả về true nếu đã lưu.
  Future<bool> save() async {
    final u = _session.user;
    if (u == null) return false;

    permissionDenied = !await _scheduler.ensurePermission();

    final r = Reminder(
      userId: u.id!,
      title: title.text.trim().isEmpty ? 'Đến giờ học bài' : title.text.trim(),
      emoji: emoji,
      hour: time.hour,
      minute: time.minute,
      repeat: repeat,
      weekday: weekday,
      date: dateKey(date),
    );
    await _reminders.save(r);
    await _scheduler.schedule(r);
    return true;
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }
}
