import 'enums.dart';

class Reminder {
  Reminder({
    this.id,
    required this.userId,
    required this.title,
    this.emoji = '⏰',
    required this.hour,
    required this.minute,
    this.repeat = RepeatKind.daily,
    this.weekday = 1,
    required this.date,
    this.enabled = true,
  });

  int? id;
  int userId;
  String title;
  String emoji;
  int hour;
  int minute;
  RepeatKind repeat;

  /// Thứ trong tuần theo chuẩn Dart/ISO: 1 = Thứ 2 ... 7 = Chủ nhật.
  int weekday;

  /// Ngày (yyyy-MM-dd), chỉ dùng khi repeat = once.
  String date;
  bool enabled;

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'emoji': emoji,
        'hour': hour,
        'minute': minute,
        'repeat': repeat.index,
        'weekday': weekday,
        'date': date,
        'enabled': enabled ? 1 : 0,
      };

  factory Reminder.fromMap(Map<String, Object?> m) => Reminder(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        title: (m['title'] ?? '') as String,
        emoji: (m['emoji'] ?? '⏰') as String,
        hour: (m['hour'] ?? 0) as int,
        minute: (m['minute'] ?? 0) as int,
        repeat: RepeatKind.values[(m['repeat'] ?? 1) as int],
        weekday: (m['weekday'] ?? 1) as int,
        date: (m['date'] ?? '') as String,
        enabled: m['enabled'] == 1,
      );
}
