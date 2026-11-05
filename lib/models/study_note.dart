/// Ghi chú nội dung học trong ngày.
class StudyNote {
  StudyNote({
    this.id,
    required this.userId,
    required this.studyDate,
    this.emoji = '📒',
    required this.content,
  });

  int? id;
  int userId;
  String studyDate;
  String emoji;
  String content;

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'study_date': studyDate,
        'emoji': emoji,
        'content': content,
      };

  factory StudyNote.fromMap(Map<String, Object?> m) => StudyNote(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        studyDate: (m['study_date'] ?? '') as String,
        emoji: (m['emoji'] ?? '📒') as String,
        content: (m['content'] ?? '') as String,
      );
}
