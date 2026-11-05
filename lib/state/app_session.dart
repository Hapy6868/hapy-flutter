import 'package:flutter/foundation.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';

/// Trạng thái dùng chung: bé đang học, từ điển đang chọn, ngày đang xem.
class AppSession extends ChangeNotifier {
  AppSession(this._users, this._lexicons, this._settings);

  final UserRepository _users;
  final LexiconRepository _lexicons;
  final SettingsRepository _settings;

  AppUser? _user;
  Lexicon? _lexicon;
  DateTime _date = dateOnly(DateTime.now());
  bool _ready = false;

  AppUser? get user => _user;
  Lexicon? get lexicon => _lexicon;
  DateTime get date => _date;

  /// false cho tới khi khôi phục xong bé đã chọn lần trước.
  bool get ready => _ready;

  Future<void> restore() async {
    final id = int.tryParse(await _settings.get('user_id') ?? '');
    final u = id == null ? null : await _users.byId(id);
    if (u != null) {
      await _select(u);
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> setUser(AppUser u) async {
    await _select(u);
    notifyListeners();
  }

  Future<void> _select(AppUser u) async {
    _user = u;
    await _settings.set('user_id', '${u.id}');
    final list = await _lexicons.forUser(u.id!);
    final saved = int.tryParse(await _settings.get('lex_${u.id}') ?? '');
    _lexicon = list.where((l) => l.id == saved).firstOrNull ?? list.firstOrNull;
    _date = dateOnly(DateTime.now());
  }

  Future<void> setLexicon(Lexicon? l) async {
    _lexicon = l;
    if (l != null && _user != null) await _settings.set('lex_${_user!.id}', '${l.id}');
    notifyListeners();
  }

  void setDate(DateTime d) {
    _date = dateOnly(d);
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    _lexicon = null;
    await _settings.remove('user_id');
    notifyListeners();
  }
}
