import 'package:pinyin/pinyin.dart';

import 'phonetic_provider.dart';

/// Tiếng Trung: pinyin có dấu thanh, tạo ngay trên máy (không cần Internet).
/// Chữ đa âm được xử lý theo từ điển của thư viện; vẫn có thể sai ở vài trường hợp, nên cho phép sửa tay.
class PinyinProvider implements PhoneticProvider {
  static final RegExp _han = RegExp(r'[\u3400-\u9fff]');

  @override
  String get language => 'zh';

  @override
  Future<PhoneticResult> forWord(String word) async => PhoneticResult(convert(word), '');

  @override
  Future<PhoneticResult> forSentence(String sentence) async => PhoneticResult(convert(sentence), '');

  static String convert(String text) {
    final t = text.trim();
    if (!_han.hasMatch(t)) return '';
    try {
      final py = PinyinHelper.getPinyinE(t, separator: ' ', format: PinyinFormat.WITH_TONE_MARK);
      return py.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      return '';
    }
  }
}
