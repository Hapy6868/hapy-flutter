/// Một bé (người học). Mỗi bé có từ điển và dữ liệu riêng.
class AppUser {
  AppUser({
    this.id,
    required this.name,
    this.emoji = '🧒',
    this.colorValue = 0xFFFFCC80,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int? id;
  String name;
  String emoji;
  int colorValue;
  DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': colorValue,
        'created_at': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        emoji: (m['emoji'] ?? '🧒') as String,
        colorValue: (m['color'] ?? 0xFFFFCC80) as int,
        createdAt: DateTime.tryParse((m['created_at'] ?? '') as String),
      );
}
