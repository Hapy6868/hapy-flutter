import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/data.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Một buổi ôn tập: phát âm tự động, hiện nghĩa theo cấu hình, ghi kết quả nhớ/chưa nhớ,
/// và chế độ tự chạy (tự đọc → tự hiện nghĩa nếu cho phép → tự sang thẻ tiếp).
class ReviewSessionViewModel extends ChangeNotifier {
  ReviewSessionViewModel({
    required List<ReviewCard> cards,
    required this.config,
    required this.speech,
    required this.entries,
  }) : _cards = List.of(cards) {
    _enter();
  }

  final ReviewConfig config;
  final SpeechService speech;
  final EntryRepository entries;

  List<ReviewCard> _cards;
  int index = 0;
  bool revealed = false;
  bool paused = false;
  bool finished = false;
  int remembered = 0;
  final List<ReviewCard> forgotten = [];

  Timer? _revealTimer;
  Timer? _advanceTimer;

  ReviewCard get card => _cards[index];
  int get total => _cards.length;
  double get progress => total == 0 ? 0 : (index + (finished ? 1 : 0)) / total;

  void _cancelTimers() {
    _revealTimer?.cancel();
    _advanceTimer?.cancel();
    _revealTimer = null;
    _advanceTimer = null;
  }

  void _scheduleTimers() {
    _cancelTimers();
    if (!revealed && config.meaningMode == MeaningMode.auto) {
      _revealTimer = Timer(Duration(seconds: config.meaningDelaySeconds), reveal);
    }
    if (config.autoAdvance && !paused) {
      _advanceTimer = Timer(Duration(seconds: config.advanceDelaySeconds), next);
    }
  }

  /// Sang thẻ hiện tại: đặt lại trạng thái, tự phát âm, hẹn giờ.
  void _enter() {
    revealed = config.meaningMode == MeaningMode.always;
    notifyListeners();
    if (config.autoSpeak) speakCurrent();
    _scheduleTimers();
  }

  Future<void> speakCurrent() => speech.speak(card.entry.text, locale: card.language.ttsLocale);

  void reveal() {
    if (revealed) return;
    revealed = true;
    notifyListeners();
  }

  void next() {
    if (index + 1 >= total) {
      _finish();
    } else {
      index++;
      _enter();
    }
  }

  void previous() {
    if (index > 0) {
      index--;
      _enter();
    }
  }

  /// Ghi kết quả (nhớ / chưa nhớ) rồi sang thẻ tiếp.
  Future<void> answer(bool remember) async {
    final id = card.entry.id;
    if (id != null) await entries.recordReview(id, remember);
    if (remember) {
      remembered++;
    } else {
      forgotten.add(card);
    }
    next();
  }

  void togglePause() {
    paused = !paused;
    if (paused) {
      _cancelTimers();
      speech.stop();
    } else {
      _scheduleTimers();
    }
    notifyListeners();
  }

  void _finish() {
    _cancelTimers();
    finished = true;
    notifyListeners();
  }

  /// Ôn lại riêng các thẻ chưa nhớ.
  void restartWithForgotten() {
    if (forgotten.isEmpty) return;
    _cards = List.of(forgotten);
    forgotten.clear();
    index = 0;
    remembered = 0;
    finished = false;
    _enter();
  }

  @override
  void dispose() {
    _cancelTimers();
    speech.stop();
    super.dispose();
  }
}
