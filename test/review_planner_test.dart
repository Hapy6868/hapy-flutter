import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hapy/models/models.dart';
import 'package:hapy/services/review_planner.dart';

VocabEntry _e(int id, {bool hard = false, int reviews = 0, DateTime? last}) => VocabEntry(
      id: id,
      lexiconId: 1,
      userId: 1,
      text: 'từ $id',
      studyDate: '2026-11-03',
      reviewCount: reviews,
      lastReviewed: last,
      hard: hard,
    );

void main() {
  final now = DateTime(2026, 11, 3, 12);

  test('chọn tối đa [count] thẻ và không trùng', () {
    final planner = ReviewPlanner(Random(1));
    final pool = [for (var i = 1; i <= 12; i++) _e(i)];
    final picked = planner.pick(pool, count: 5, now: now);
    expect(picked.length, 5);
    expect(picked.map((e) => e.id).toSet().length, 5);
  });

  test('kho ít hơn số cần lấy thì lấy hết', () {
    final planner = ReviewPlanner(Random(1));
    expect(planner.pick([_e(1), _e(2)], count: 10, now: now).length, 2);
    expect(planner.pick([], count: 10, now: now), isEmpty);
  });

  test('ưu tiên "từ khó nhớ" khi người dùng chọn như vậy', () {
    final planner = ReviewPlanner(Random(7));
    final pool = [for (var i = 1; i <= 10; i++) _e(i, hard: i == 3 || i == 7, reviews: 2, last: now)];
    final picked = planner.pick(pool, count: 2, focus: ReviewFocus.hard, now: now);
    expect(picked.map((e) => e.id).toSet(), {3, 7});
  });

  test('từ chưa ôn lần nào được ưu tiên hơn từ vừa ôn xong', () {
    final planner = ReviewPlanner(Random(3));
    final reviewedJustNow = _e(1, reviews: 5, last: now);
    final neverReviewed = _e(2);
    for (var i = 0; i < 20; i++) {
      final picked = planner.pick([reviewedJustNow, neverReviewed], count: 1, now: now);
      expect(picked.single.id, 2);
    }
  });
}
