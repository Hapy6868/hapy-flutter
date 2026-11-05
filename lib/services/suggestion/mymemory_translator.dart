import 'dart:convert';

import 'package:http/http.dart' as http;

import 'translator.dart';

/// Dịch bằng API miễn phí của MyMemory (có giới hạn lượt/ngày).
/// Kết quả là dịch tự động, cần người lớn kiểm tra.
class MyMemoryTranslator implements Translator {
  MyMemoryTranslator(this._client);
  final http.Client _client;

  @override
  Future<String> translate(String text, String from, String to) async {
    final uri = Uri.parse('https://api.mymemory.translated.net/get'
        '?q=${Uri.encodeQueryComponent(text)}&langpair=${Uri.encodeQueryComponent('$from|$to')}');
    final r = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return '';
    return parse(utf8.decode(r.bodyBytes));
  }

  static String parse(String body) {
    try {
      final t = ((jsonDecode(body) as Map)['responseData'] as Map)['translatedText'];
      final s = (t ?? '').toString();
      if (s.toUpperCase().startsWith('MYMEMORY WARNING')) return '';
      return s
          .replaceAll('&#39;', "'")
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .trim();
    } catch (_) {
      return '';
    }
  }
}
