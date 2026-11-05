import 'package:flutter/foundation.dart';

import '../core/palette.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'app_session.dart';

class UserPickerViewModel extends ChangeNotifier {
  UserPickerViewModel(this._users, this._reminders, this._scheduler, this._session);

  final UserRepository _users;
  final ReminderRepository _reminders;
  final ReminderScheduler _scheduler;
  final AppSession _session;

  List<AppUser> users = [];
  bool loading = true;

  Future<void> load() async {
    users = await _users.all();
    loading = false;
    notifyListeners();
  }

  Future<void> select(AppUser u) => _session.setUser(u);

  Future<void> add(String name, String emoji) async {
    final color = Palette.userColors[users.length % Palette.userColors.length];
    final user = await _users.create(name: name, emoji: emoji, colorValue: color);
    await load();
    await _session.setUser(user);
  }

  Future<void> remove(AppUser u) async {
    for (final r in await _reminders.forUser(u.id!)) {
      await _scheduler.cancel(r.id!);
    }
    await _users.delete(u.id!);
    await load();
  }
}
