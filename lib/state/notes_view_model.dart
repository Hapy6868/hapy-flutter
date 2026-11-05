import 'package:flutter/foundation.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';
import 'app_session.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel(this._session, this._notes) {
    _session.addListener(load);
  }

  final AppSession _session;
  final NoteRepository _notes;

  List<StudyNote> items = [];

  Future<void> load() async {
    final u = _session.user;
    items = u == null ? [] : await _notes.forDay(u.id!, dateKey(_session.date));
    notifyListeners();
  }

  Future<void> add(String content, String emoji) async {
    final u = _session.user;
    if (u == null) return;
    await _notes.save(StudyNote(
        userId: u.id!, studyDate: dateKey(_session.date), emoji: emoji, content: content));
    await load();
  }

  Future<void> remove(StudyNote n) async {
    await _notes.delete(n.id!);
    await load();
  }

  @override
  void dispose() {
    _session.removeListener(load);
    super.dispose();
  }
}
