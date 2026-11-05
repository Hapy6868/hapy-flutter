import '../../models/models.dart';
import 'phonetic_provider.dart';
import 'translator.dart';

class Suggestion {
  const Suggestion({this.phonetic = '', this.meaning = '', this.example = '', this.partial = false});

  final String phonetic;
  final String meaning;
  final String example;

  /// true nếu chỉ tìm được một phần.
  final bool partial;
}

/// Gộp phiên âm + nghĩa + ví dụ thành một gợi ý cho từ hoặc câu, theo ngôn ngữ của từ điển.
abstract class SuggestionService {
  Future<Suggestion> suggest(String text, EntryKind kind, String from, String to);
}

/// Chọn đúng PhoneticProvider theo ngôn ngữ [from], và dịch nghĩa bằng Translator.
/// Mọi lỗi mạng đều được nuốt lại: trả về gợi ý rỗng để người dùng tự nhập.
class OnlineSuggestionService implements SuggestionService {
  OnlineSuggestionService(Iterable<PhoneticProvider> providers, this._translator)
      : _providers = {for (final p in providers) p.language: p};

  final Map<String, PhoneticProvider> _providers;
  final Translator _translator;

  @override
  Future<Suggestion> suggest(String text, EntryKind kind, String from, String to) async {
    text = text.trim();
    if (text.isEmpty) return const Suggestion();

    final lang = AppLanguage.byCode(from);
    final provider = _providers[lang.code];

    final meaningFuture = _safe(() => _translator.translate(text, lang.translateCode, to), '');
    final phoneticResult = provider == null
        ? PhoneticResult.empty
        : await _safe(
            () => kind == EntryKind.word ? provider.forWord(text) : provider.forSentence(text),
            PhoneticResult.empty,
          );
    final meaning = await meaningFuture;

    return Suggestion(
      phonetic: phoneticResult.phonetic,
      meaning: meaning,
      example: phoneticResult.example,
      partial: phoneticResult.partial || phoneticResult.phonetic.isEmpty || meaning.isEmpty,
    );
  }

  static Future<T> _safe<T>(Future<T> Function() action, T fallback) async {
    try {
      return await action();
    } catch (_) {
      return fallback;
    }
  }
}
