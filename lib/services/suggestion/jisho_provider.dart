import 'dart:convert';

import 'package:http/http.dart' as http;

import 'kana_romaji.dart';
import 'phonetic_provider.dart';

/// Tiếng Nhật: cách đọc (kana • romaji).
/// - Từ: tra jisho.org (miễn phí, cần Internet) để lấy cách đọc của chữ Hán.
/// - Câu viết hoàn toàn bằng kana: đổi sang romaji ngay trên máy.
/// - Câu có chữ Hán: chưa tự tạo được cách đọc (cần bộ tách từ), trả về "một phần" để người dùng nhập tay.
class JishoProvider implements PhoneticProvider {
  JishoProvider(this._client);
  final http.Client _client;

  @override
  String get language => 'ja';

  @override
  Future<PhoneticResult> forWord(String word) async {
    final w = word.trim();
    if (w.isEmpty) return PhoneticResult.empty;
    if (KanaRomaji.isAllKana(w)) return PhoneticResult(KanaRomaji.reading(w), '');

    final uri = Uri.parse('https://jisho.org/api/v1/search/words?keyword=${Uri.encodeQueryComponent(w)}');
    final r = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return PhoneticResult.empty;
    return parse(utf8.decode(r.bodyBytes), w);
  }

  @override
  Future<PhoneticResult> forSentence(String sentence) async {
    final s = sentence.trim();
    if (s.isEmpty) return PhoneticResult.empty;
    if (KanaRomaji.isAllKana(s)) return PhoneticResult(KanaRomaji.reading(s), '');
    return const PhoneticResult('', '', partial: true);
  }

  /// Tách riêng để kiểm thử không cần mạng.
  static PhoneticResult parse(String body, String query) {
    try {
      final data = (jsonDecode(body) as Map)['data'];
      if (data is! List || data.isEmpty) return PhoneticResult.empty;

      String? reading;
      for (final item in data) {
        final jp = (item as Map)['japanese'];
        if (jp is! List) continue;
        for (final j in jp) {
          final m = j as Map;
          if (m['word'] == query || m['reading'] == query) {
            reading = m['reading'] as String?;
            break;
          }
        }
        if (reading != null) break;
      }

      if (reading == null) {
        final firstJp = (data.first as Map)['japanese'];
        if (firstJp is List && firstJp.isNotEmpty) {
          reading = (firstJp.first as Map)['reading'] as String?;
        }
      }

      if (reading == null || reading.isEmpty) return PhoneticResult.empty;
      return PhoneticResult(KanaRomaji.reading(reading), '');
    } catch (_) {
      return PhoneticResult.empty;
    }
  }
}
