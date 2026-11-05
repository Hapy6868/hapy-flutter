import 'enums.dart';
import 'language.dart';

/// Một từ điển của một bé (ví dụ "Động vật", "Câu chào hỏi").
class Lexicon {
  Lexicon({
    this.id,
    required this.userId,
    required this.name,
    this.emoji = '📚',
    this.kind = EntryKind.word,
    this.sourceLang = 'en',
    this.targetLang = 'vi',
  });

  int? id;
  int userId;
  String name;
  String emoji;
  EntryKind kind;
  String sourceLang;
  String targetLang;

  AppLanguage get language => AppLanguage.byCode(sourceLang);

  String get label => '$emoji $name • ${language.flag} ${kind == EntryKind.word ? 'Từ' : 'Câu'}';

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'emoji': emoji,
        'kind': kind.index,
        'source_lang': sourceLang,
        'target_lang': targetLang,
      };

  factory Lexicon.fromMap(Map<String, Object?> m) => Lexicon(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        name: (m['name'] ?? '') as String,
        emoji: (m['emoji'] ?? '📚') as String,
        kind: EntryKind.values[(m['kind'] ?? 0) as int],
        sourceLang: (m['source_lang'] ?? 'en') as String,
        targetLang: (m['target_lang'] ?? 'vi') as String,
      );
}
