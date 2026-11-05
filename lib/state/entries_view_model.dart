import 'package:flutter/foundation.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';
import 'app_session.dart';

/// Danh sách từ/câu của từ điển đang chọn (theo ngày hoặc tất cả).
class EntriesViewModel extends ChangeNotifier {
  EntriesViewModel(this._session, this._entries) {
    _session.addListener(load);
  }

  final AppSession _session;
  final EntryRepository _entries;

  List<VocabEntry> items = [];
  bool showAll = false;

  Lexicon? get lexicon => _session.lexicon;

  Future<void> load() async {
    final l = _session.lexicon;
    items = l == null
        ? []
        : await _entries.list(l.id!, date: showAll ? null : dateKey(_session.date));
    notifyListeners();
  }

  void setShowAll(bool v) {
    showAll = v;
    load();
  }

  Future<void> remove(VocabEntry e) async {
    await _entries.delete(e.id!);
    await load();
  }

  @override
  void dispose() {
    _session.removeListener(load);
    super.dispose();
  }
}
