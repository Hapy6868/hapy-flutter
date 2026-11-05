import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hapy/models/models.dart';
import 'package:hapy/services/suggestion/suggestion.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeProvider implements PhoneticProvider {
  _FakeProvider(this.language, this.words);

  @override
  final String language;
  final Map<String, String> words;

  @override
  Future<PhoneticResult> forWord(String word) async => PhoneticResult(words[word] ?? '', 'ví dụ');

  @override
  Future<PhoneticResult> forSentence(String sentence) async => PhoneticResult(words[sentence] ?? '', '');
}

class _FakeTranslator implements Translator {
  String? lastFrom;

  @override
  Future<String> translate(String text, String from, String to) async {
    lastFrom = from;
    return 'nghĩa';
  }
}

http.Response _utf8(String body, [int status = 200]) => http.Response.bytes(utf8.encode(body), status);

void main() {
  group('DictionaryApiProvider (tiếng Anh)', () {
    test('parse: đọc phiên âm và câu ví dụ', () {
      const json =
          '[{"word":"hello","phonetic":"/həˈləʊ/","meanings":[{"definitions":[{"definition":"x","example":"Hello, world!"}]}]}]';
      final r = DictionaryApiProvider.parse(json);
      expect(r.phonetic, '/həˈləʊ/');
      expect(r.example, 'Hello, world!');
    });

    test('parse: lấy phiên âm từ danh sách phonetics', () {
      const json = '[{"word":"cat","phonetics":[{"audio":""},{"text":"/kæt/"}],"meanings":[]}]';
      expect(DictionaryApiProvider.parse(json).phonetic, '/kæt/');
    });

    test('parse: không tìm thấy từ thì rỗng', () {
      expect(DictionaryApiProvider.parse('{"title":"No Definitions Found"}').phonetic, '');
    });

    final client = MockClient((req) async {
      if (req.url.path.endsWith('/hello')) return _utf8('[{"phonetic":"/həˈləʊ/"}]');
      if (req.url.path.endsWith('/world')) return _utf8('[{"phonetic":"/wɜːld/"}]');
      return _utf8('{"title":"No Definitions Found"}', 404);
    });
    final provider = DictionaryApiProvider(client);

    test('câu: ghép phiên âm từng từ', () async {
      final r = await provider.forSentence('Hello world!');
      expect(r.phonetic, '/həˈləʊ wɜːld/');
      expect(r.partial, false);
    });

    test('câu: đánh dấu một phần khi thiếu từ', () async {
      final r = await provider.forSentence('Hello zzz');
      expect(r.phonetic, '/həˈləʊ zzz/');
      expect(r.partial, true);
    });

    test('câu: không tra được từ nào thì để trống', () async {
      final r = await provider.forSentence('zzz yyy');
      expect(r.phonetic, '');
      expect(r.partial, true);
    });
  });

  group('JishoProvider (tiếng Nhật)', () {
    test('parse: lấy cách đọc và đổi sang romaji', () {
      const json = '{"data":[{"japanese":[{"word":"猫","reading":"ねこ"}]}]}';
      expect(JishoProvider.parse(json, '猫').phonetic, 'ねこ • neko');
    });

    test('parse: ưu tiên kết quả khớp đúng từ', () {
      const json = '{"data":[{"japanese":[{"word":"学校長","reading":"がっこうちょう"}]},'
          '{"japanese":[{"word":"学校","reading":"がっこう"}]}]}';
      expect(JishoProvider.parse(json, '学校').phonetic, 'がっこう • gakkou');
    });

    test('parse: dữ liệu rỗng', () {
      expect(JishoProvider.parse('{"data":[]}', '猫').phonetic, '');
    });

    final provider = JishoProvider(MockClient((_) async => _utf8('{"data":[]}', 500)));

    test('câu toàn kana được đổi sang romaji ngay trên máy', () async {
      final r = await provider.forSentence('こんにちは');
      expect(r.phonetic, 'こんにちは • konnichiha');
    });

    test('câu có chữ Hán: chưa tự tạo được, đánh dấu một phần', () async {
      final r = await provider.forSentence('私は学生です');
      expect(r.phonetic, '');
      expect(r.partial, true);
    });
  });

  group('PinyinProvider (tiếng Trung)', () {
    test('có dấu thanh', () {
      expect(PinyinProvider.convert('你好'), 'nǐ hǎo');
    });

    test('không có chữ Hán thì để trống', () {
      expect(PinyinProvider.convert('Hello'), '');
    });
  });

  group('MyMemoryTranslator.parse', () {
    test('bỏ qua cảnh báo hết lượt', () {
      expect(MyMemoryTranslator.parse('{"responseData":{"translatedText":"MYMEMORY WARNING: quota"}}'), '');
    });

    test('giải mã ký tự đặc biệt', () {
      expect(MyMemoryTranslator.parse('{"responseData":{"translatedText":"it&#39;s"}}'), "it's");
    });
  });

  group('OnlineSuggestionService', () {
    test('chọn nhà cung cấp theo ngôn ngữ và đổi mã ngôn ngữ khi dịch', () async {
      final tr = _FakeTranslator();
      final service = OnlineSuggestionService([
        _FakeProvider('en', {'hello': '/həˈləʊ/'}),
        _FakeProvider('ja', {'ねこ': 'ねこ • neko'}),
      ], tr);

      final ja = await service.suggest('ねこ', EntryKind.word, 'ja', 'vi');
      expect(ja.phonetic, 'ねこ • neko');
      expect(ja.meaning, 'nghĩa');
      expect(tr.lastFrom, 'ja');

      final en = await service.suggest('hello', EntryKind.word, 'en', 'vi');
      expect(en.phonetic, '/həˈləʊ/');
      expect(en.partial, false);
    });

    test('ngôn ngữ chưa có nhà cung cấp: vẫn dịch, phiên âm rỗng, đánh dấu một phần', () async {
      final tr = _FakeTranslator();
      final service = OnlineSuggestionService([_FakeProvider('en', {})], tr);
      final zh = await service.suggest('你好', EntryKind.word, 'zh', 'vi');
      expect(zh.phonetic, '');
      expect(zh.meaning, 'nghĩa');
      expect(zh.partial, true);
      expect(tr.lastFrom, 'zh-CN');
    });
  });

  group('Model', () {
    test('VocabEntry giữ nguyên thông tin ôn tập', () {
      final e = VocabEntry(
        lexiconId: 1,
        userId: 2,
        text: 'cat',
        meaning: 'con mèo',
        meaningEdited: true,
        studyDate: '2026-11-02',
        reviewCount: 3,
        lastReviewed: DateTime(2026, 11, 3, 9),
        hard: true,
      );
      final back = VocabEntry.fromMap(e.toMap());
      expect(back.text, 'cat');
      expect(back.meaningEdited, true);
      expect(back.reviewCount, 3);
      expect(back.lastReviewed, DateTime(2026, 11, 3, 9));
      expect(back.hard, true);
    });

    test('Reminder giữ nguyên kiểu lặp', () {
      final r = Reminder(
          userId: 1, title: 'Học', hour: 19, minute: 30, repeat: RepeatKind.weekly, weekday: 3, date: '2026-11-02');
      final back = Reminder.fromMap(r.toMap());
      expect(back.repeat, RepeatKind.weekly);
      expect(back.weekday, 3);
    });

    test('AppLanguage và nhãn từ điển', () {
      expect(AppLanguage.byCode('ja').ttsLocale, 'ja-JP');
      expect(AppLanguage.byCode('zh').sttLocale, 'zh_CN');
      expect(AppLanguage.byCode('xx').code, 'en');
      final lex = Lexicon(userId: 1, name: 'Động vật', sourceLang: 'ja', kind: EntryKind.sentence);
      expect(lex.label.contains('🇯🇵'), true);
      expect(lex.label.contains('Câu'), true);
    });
  });
}
