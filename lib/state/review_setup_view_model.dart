import 'package:flutter/foundation.dart';

import '../core/date_keys.dart';
import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'app_session.dart';

/// Màn hình chọn cách ôn: số từ, nguồn, thời gian, ưu tiên, phát âm, hiện nghĩa...
class ReviewSetupViewModel extends ChangeNotifier {
  ReviewSetupViewModel(this._session, this._entries, this._lexicons, this._planner) {
    config = ReviewConfig(
      scope: _session.lexicon == null ? ReviewScope.allLexicons : ReviewScope.currentLexicon,
    );
  }

  final AppSession _session;
  final EntryRepository _entries;
  final LexiconRepository _lexicons;
  final ReviewPlanner _planner;

  late final ReviewConfig config;
  bool busy = false;
  String message = '';

  Lexicon? get currentLexicon => _session.lexicon;

  void update(void Function() change) {
    change();
    notifyListeners();
  }

  /// Tự động chọn từ theo cấu hình. Rỗng nếu chưa có từ phù hợp ([message] giải thích lý do).
  Future<List<ReviewCard>> buildCards() async {
    final user = _session.user;
    if (user == null) return [];

    busy = true;
    message = '';
    notifyListeners();
    try {
      final today = dateOnly(DateTime.now());
      final since = switch (config.range) {
        ReviewRange.today => dateKey(today),
        ReviewRange.week => dateKey(today.subtract(const Duration(days: 6))),
        ReviewRange.all => null,
      };

      final lexiconId = config.scope == ReviewScope.currentLexicon ? _session.lexicon?.id : null;
      final pool = (await _entries.forReview(user.id!, lexiconId: lexiconId, sinceDate: since))
          .where((e) => e.text.trim().isNotEmpty)
          .toList();

      final byId = {for (final l in await _lexicons.forUser(user.id!)) l.id!: l};
      final picked = _planner.pick(pool, count: config.count, focus: config.focus);

      if (picked.isEmpty) {
        message = 'Chưa có từ/câu nào phù hợp. Hãy thêm từ mới hoặc chọn "Tất cả" ở phần thời gian nhé.';
      }
      return [for (final e in picked) ReviewCard(e, byId[e.lexiconId]?.language ?? AppLanguage.en)];
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
