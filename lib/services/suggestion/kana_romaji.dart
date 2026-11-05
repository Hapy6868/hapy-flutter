/// Đổi kana (hiragana/katakana) sang romaji kiểu Hepburn đơn giản. Dart thuần, chạy offline.
class KanaRomaji {
  static const Map<String, String> _base = {
    'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
    'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
    'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
    'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
    'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
    'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
    'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
    'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
    'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
    'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
    'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
    'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
    'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
    'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
    'わ': 'wa', 'を': 'o', 'ん': 'n', 'ゔ': 'vu',
  };

  /// Chữ nhỏ ゃ ゅ ょ (ghép với chữ đứng trước).
  static const Map<String, String> _smallY = {'ゃ': 'ya', 'ゅ': 'yu', 'ょ': 'yo'};

  /// Chữ nhỏ ぁ ぃ ぅ ぇ ぉ (thường gặp trong katakana: ファ, ティ...).
  static const Map<String, String> _smallVowel = {'ぁ': 'a', 'ぃ': 'i', 'ぅ': 'u', 'ぇ': 'e', 'ぉ': 'o'};

  static final RegExp _ignorable = RegExp(r'[\s、。！？!?,.・「」『』〜~…]');

  static bool _isKanaRune(int r) =>
      (r >= 0x3041 && r <= 0x3096) || (r >= 0x30A1 && r <= 0x30FA) || r == 0x30FC;

  /// true nếu toàn bộ chữ (bỏ khoảng trắng, dấu câu) đều là kana.
  static bool isAllKana(String s) {
    final cleaned = s.replaceAll(_ignorable, '');
    return cleaned.isNotEmpty && cleaned.runes.every(_isKanaRune);
  }

  /// Hiển thị cách đọc: "ねこ • neko".
  static String reading(String kana) => '$kana • ${toRomaji(kana)}';

  static String _toHiragana(String s) => String.fromCharCodes(
        s.runes.map((r) => (r >= 0x30A1 && r <= 0x30F6) ? r - 0x60 : r),
      );

  static String toRomaji(String input) {
    final chars = _toHiragana(input).runes.map(String.fromCharCode).toList();
    final out = <String>[];
    var sokuon = false;

    for (final c in chars) {
      if (c == 'っ') {
        sokuon = true;
        continue;
      }
      if (c == 'ー') {
        if (out.isNotEmpty) {
          final last = out.last;
          if (last.isNotEmpty && 'aiueo'.contains(last[last.length - 1])) out.add(last[last.length - 1]);
        }
        continue;
      }
      if (_smallY.containsKey(c) && out.isNotEmpty) {
        out.add(_digraph(out.removeLast(), _smallY[c]!));
        continue;
      }
      if (_smallVowel.containsKey(c) && out.isNotEmpty) {
        final prev = out.removeLast();
        out.add(prev.replaceFirst(RegExp(r'[aiueo]+$'), '') + _smallVowel[c]!);
        continue;
      }

      var r = _base[c] ?? c;
      if (sokuon) {
        if (r.isNotEmpty && RegExp(r'[a-z]').hasMatch(r[0]) && !'aiueo'.contains(r[0])) {
          r = (r.startsWith('ch') ? 't' : r[0]) + r;
        }
        sokuon = false;
      }
      out.add(r);
    }
    return out.join();
  }

  static String _digraph(String prev, String small) {
    final vowel = small.substring(1);
    if (prev.endsWith('i')) {
      final c = prev.substring(0, prev.length - 1);
      if (c == 'sh' || c == 'ch' || c == 'j') return c + vowel;
      return '${c}y$vowel';
    }
    return prev + small;
  }
}
