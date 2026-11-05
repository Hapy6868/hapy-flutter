import 'dart:convert';

import 'package:http/http.dart' as http;

import 'phonetic_provider.dart';

/// Tiếng Anh: phiên âm IPA và câu ví dụ từ api.dictionaryapi.dev (miễn phí, cần Internet).
/// Với câu: ghép phiên âm của từng từ.
class DictionaryApiProvider implements PhoneticProvider {
  DictionaryApiProvider(this._client);
  final http.Client _client;

  static const int maxWords = 20;
  static final RegExp _wordPattern = RegExp(r"[A-Za-z]+(?:'[A-Za-z]+)?");

  @override
  String get language => 'en';

  @override
  Future<PhoneticResult> forWord(String word) async {
    final uri = Uri.parse(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(word.trim().toLowerCase())}');
    final r = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) return PhoneticResult.empty;
    return parse(utf8.decode(r.bodyBytes));
  }

  @override
  Future<PhoneticResult> forSentence(String sentence) async {
    final tokens = _wordPattern.allMatches(sentence).map((m) => m.group(0)!).take(maxWords).toList();
    if (tokens.isEmpty) return PhoneticResult.empty;

    final unique = <String>{...tokens.map((t) => t.toLowerCase())}.toList();
    final map = <String, String>{};

    // Tra phiên âm từng từ, mỗi lượt 4 từ để không dồn quá nhiều yêu cầu.
    for (var i = 0; i < unique.length; i += 4) {
      final chunk = unique.skip(i).take(4).toList();
      final results = await Future.wait(chunk.map(_safeWord));
      for (var j = 0; j < chunk.length; j++) {
        map[chunk[j]] = results[j].phonetic;
      }
    }

    var missing = false;
    var found = 0;
    final parts = tokens.map((t) {
      final p = map[t.toLowerCase()] ?? '';
      if (p.isNotEmpty) {
        found++;
        return p.replaceAll(RegExp(r'^[/\[\s]+|[/\]\s]+$'), '');
      }
      missing = true;
      return t;
    }).toList();

    if (found == 0) return const PhoneticResult('', '', partial: true);
    return PhoneticResult('/${parts.join(' ')}/', '', partial: missing);
  }

  Future<PhoneticResult> _safeWord(String w) async {
    try {
      return await forWord(w);
    } catch (_) {
      return PhoneticResult.empty;
    }
  }

  /// Tách riêng để kiểm thử không cần mạng.
  static PhoneticResult parse(String body) {
    try {
      final data = jsonDecode(body);
      if (data is! List || data.isEmpty || data.first is! Map) return PhoneticResult.empty;
      final e = data.first as Map;

      var phonetic = (e['phonetic'] ?? '').toString();
      if (phonetic.isEmpty && e['phonetics'] is List) {
        for (final x in e['phonetics'] as List) {
          final t = x is Map ? (x['text'] ?? '').toString() : '';
          if (t.isNotEmpty) {
            phonetic = t;
            break;
          }
        }
      }

      var example = '';
      if (e['meanings'] is List) {
        outer:
        for (final m in e['meanings'] as List) {
          if (m is! Map || m['definitions'] is! List) continue;
          for (final d in m['definitions'] as List) {
            final ex = d is Map ? (d['example'] ?? '').toString() : '';
            if (ex.isNotEmpty) {
              example = ex;
              break outer;
            }
          }
        }
      }
      return PhoneticResult(phonetic, example);
    } catch (_) {
      return PhoneticResult.empty;
    }
  }
}
