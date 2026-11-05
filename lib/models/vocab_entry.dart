/// Một từ hoặc một câu trong từ điển.
///
/// `autoPhonetic` / `autoMeaning` là GỢI Ý gốc của hệ thống;
/// `phonetic` / `meaning` là bản cuối cùng do bé hoặc phụ huynh chọn.
class VocabEntry {
  VocabEntry({
    this.id,
    required this.lexiconId,
    required this.userId,
    required this.text,
    this.phonetic = '',
    this.meaning = '',
    this.example = '',
    this.autoPhonetic = '',
    this.autoMeaning = '',
    this.phoneticEdited = false,
    this.meaningEdited = false,
    this.image = '',
    required this.studyDate,
    DateTime? createdAt,
    this.reviewCount = 0,
    this.lastReviewed,
    this.hard = false,
  }) : createdAt = createdAt ?? DateTime.now();

  int? id;
  int lexiconId;
  int userId;
  String text;
  String phonetic;
  String meaning;
  String example;
  String autoPhonetic;
  String autoMeaning;
  bool phoneticEdited;
  bool meaningEdited;
  String image;
  String studyDate;
  DateTime createdAt;

  /// Số lần đã ôn, lần ôn gần nhất, và có đang "khó nhớ" không.
  int reviewCount;
  DateTime? lastReviewed;
  bool hard;

  Map<String, Object?> toMap() => {
        'id': id,
        'lexicon_id': lexiconId,
        'user_id': userId,
        'text': text,
        'phonetic': phonetic,
        'meaning': meaning,
        'example': example,
        'auto_phonetic': autoPhonetic,
        'auto_meaning': autoMeaning,
        'phonetic_edited': phoneticEdited ? 1 : 0,
        'meaning_edited': meaningEdited ? 1 : 0,
        'image': image,
        'study_date': studyDate,
        'created_at': createdAt.toIso8601String(),
        'review_count': reviewCount,
        'last_reviewed': lastReviewed?.toIso8601String(),
        'hard': hard ? 1 : 0,
      };

  factory VocabEntry.fromMap(Map<String, Object?> m) => VocabEntry(
        id: m['id'] as int?,
        lexiconId: m['lexicon_id'] as int,
        userId: m['user_id'] as int,
        text: (m['text'] ?? '') as String,
        phonetic: (m['phonetic'] ?? '') as String,
        meaning: (m['meaning'] ?? '') as String,
        example: (m['example'] ?? '') as String,
        autoPhonetic: (m['auto_phonetic'] ?? '') as String,
        autoMeaning: (m['auto_meaning'] ?? '') as String,
        phoneticEdited: m['phonetic_edited'] == 1,
        meaningEdited: m['meaning_edited'] == 1,
        image: (m['image'] ?? '') as String,
        studyDate: (m['study_date'] ?? '') as String,
        createdAt: DateTime.tryParse((m['created_at'] ?? '') as String),
        reviewCount: (m['review_count'] ?? 0) as int,
        lastReviewed: m['last_reviewed'] == null ? null : DateTime.tryParse(m['last_reviewed'] as String),
        hard: m['hard'] == 1,
      );
}
