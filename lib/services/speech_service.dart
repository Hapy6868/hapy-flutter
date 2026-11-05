import 'package:flutter_tts/flutter_tts.dart';

/// Đọc to bằng giọng của hệ thống. [locale] ví dụ en-US, ja-JP, zh-CN.
/// Trên iPhone nhớ tắt chế độ im lặng; giọng Nhật/Trung có thể cần tải trong Cài đặt → Trợ năng → Nội dung được đọc.
class SpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    try {
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    } catch (_) {}
  }

  Future<void> speak(String text, {String locale = 'en-US'}) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.4);
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
