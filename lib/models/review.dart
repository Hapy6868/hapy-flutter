import 'language.dart';
import 'vocab_entry.dart';

/// Lấy từ ở đâu để ôn.
enum ReviewScope { currentLexicon, allLexicons }

/// Lấy từ học trong khoảng thời gian nào.
enum ReviewRange { today, week, all }

/// Ưu tiên khi tự động chọn từ.
enum ReviewFocus { auto, hard, newest }

/// Nghĩa được hiện như thế nào: chạm mới xem / tự hiện sau vài giây / luôn hiện.
enum MeaningMode { tap, auto, always }

/// Cấu hình một buổi ôn tập.
class ReviewConfig {
  ReviewConfig({
    this.count = 10,
    this.scope = ReviewScope.currentLexicon,
    this.range = ReviewRange.all,
    this.focus = ReviewFocus.auto,
    this.autoSpeak = true,
    this.showPhonetic = true,
    this.meaningMode = MeaningMode.tap,
    this.autoAdvance = false,
    this.meaningDelaySeconds = 3,
    this.advanceDelaySeconds = 7,
  });

  int count;
  ReviewScope scope;
  ReviewRange range;
  ReviewFocus focus;

  /// Tự phát âm mỗi khi sang thẻ mới.
  bool autoSpeak;
  bool showPhonetic;
  MeaningMode meaningMode;

  /// Chế độ tự chạy (như trình chiếu): tự đọc, tự hiện nghĩa (nếu cho phép), tự sang thẻ tiếp.
  bool autoAdvance;
  int meaningDelaySeconds;
  int advanceDelaySeconds;
}

/// Một thẻ ôn tập: từ/câu kèm ngôn ngữ của từ điển chứa nó (để chọn giọng đọc).
class ReviewCard {
  const ReviewCard(this.entry, this.language);

  final VocabEntry entry;
  final AppLanguage language;
}
