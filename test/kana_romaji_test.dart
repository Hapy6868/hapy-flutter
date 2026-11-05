import 'package:flutter_test/flutter_test.dart';
import 'package:hapy/services/suggestion/kana_romaji.dart';

void main() {
  group('KanaRomaji.toRomaji', () {
    test('hiragana cơ bản', () {
      expect(KanaRomaji.toRomaji('ねこ'), 'neko');
      expect(KanaRomaji.toRomaji('さくら'), 'sakura');
      expect(KanaRomaji.toRomaji('こんにちは'), 'konnichiha');
    });

    test('âm ngắt っ nhân đôi phụ âm', () {
      expect(KanaRomaji.toRomaji('がっこう'), 'gakkou');
      expect(KanaRomaji.toRomaji('ざっし'), 'zasshi');
    });

    test('âm ghép ゃ ゅ ょ', () {
      expect(KanaRomaji.toRomaji('きょう'), 'kyou');
      expect(KanaRomaji.toRomaji('しゃしん'), 'shashin');
      expect(KanaRomaji.toRomaji('じゅう'), 'juu');
    });

    test('katakana và trường âm ー', () {
      expect(KanaRomaji.toRomaji('ラーメン'), 'raamen');
      expect(KanaRomaji.toRomaji('ファイル'), 'fairu');
    });
  });

  group('KanaRomaji.isAllKana', () {
    test('nhận biết chuỗi toàn kana (bỏ dấu câu, khoảng trắng)', () {
      expect(KanaRomaji.isAllKana('こんにちは'), true);
      expect(KanaRomaji.isAllKana('ありがとう、ございます。'), true);
      expect(KanaRomaji.isAllKana('学校'), false);
      expect(KanaRomaji.isAllKana(''), false);
      expect(KanaRomaji.isAllKana('hello'), false);
    });
  });
}
