import 'dart:math';

import '../models/models.dart';

/// Tự động chọn từ/câu để ôn tập. Dart thuần nên kiểm thử được.
///
/// Điểm ưu tiên: chưa ôn lần nào (+3), đang "khó nhớ" (+4, hoặc +20 nếu chọn ưu tiên từ khó),
/// lâu chưa ôn (tối đa +3), mới thêm (tối đa +10 nếu chọn ưu tiên từ mới), cộng thêm chút ngẫu nhiên.
class ReviewPlanner {
  ReviewPlanner([Random? random]) : _random = random ?? Random();

  final Random _random;

  List<VocabEntry> pick(
    List<VocabEntry> pool, {
    required int count,
    ReviewFocus focus = ReviewFocus.auto,
    DateTime? now,
  }) {
    if (pool.isEmpty || count <= 0) return [];
    final t = now ?? DateTime.now();

    final scored = pool.map((e) => MapEntry(e, _score(e, focus, t))).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scored.take(count).map((m) => m.key).toList()..shuffle(_random);
  }

  double _score(VocabEntry e, ReviewFocus focus, DateTime now) {
    var s = _random.nextDouble() * 1.5;
    if (e.reviewCount == 0) s += 3;
    if (e.hard) s += focus == ReviewFocus.hard ? 20 : 4;

    final last = e.lastReviewed;
    if (last != null) s += now.difference(last).inDays.clamp(0, 30).toDouble() / 10;

    if (focus == ReviewFocus.newest) {
      final age = now.difference(e.createdAt).inDays.clamp(0, 30).toDouble();
      s += (30 - age) / 3;
    }
    return s;
  }
}
