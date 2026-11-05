import 'package:http/http.dart' as http;

import '../data/data.dart';
import '../services/services.dart';
import '../state/state.dart';

/// Nơi DUY NHẤT tạo và nối các đối tượng với nhau.
/// Muốn thay một thành phần (ví dụ nguồn dịch khác, thêm ngôn ngữ mới, server đồng bộ khác)
/// chỉ cần sửa file này; giao diện và logic không phải đổi.
class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.users,
    required this.lexicons,
    required this.entries,
    required this.notes,
    required this.reminders,
    required this.settings,
    required this.speech,
    required this.voice,
    required this.images,
    required this.scheduler,
    required this.suggestions,
    required this.planner,
    required this.sync,
    required this.session,
  });

  final AppDatabase database;
  final UserRepository users;
  final LexiconRepository lexicons;
  final EntryRepository entries;
  final NoteRepository notes;
  final ReminderRepository reminders;
  final SettingsRepository settings;
  final SpeechService speech;
  final VoiceInputService voice;
  final ImageStore images;
  final ReminderScheduler scheduler;
  final SuggestionService suggestions;
  final ReviewPlanner planner;
  final SyncService sync;
  final AppSession session;

  static Future<AppDependencies> create() async {
    final database = await AppDatabase.open();
    final client = http.Client();

    final speech = SpeechService();
    await speech.init();
    final images = ImageStore();
    await images.init();
    final scheduler = LocalReminderScheduler();
    await scheduler.init();

    final users = UserRepository(database);
    final lexicons = LexiconRepository(database);
    final settings = SettingsRepository(database);
    final session = AppSession(users, lexicons, settings);
    await session.restore();

    return AppDependencies._(
      database: database,
      users: users,
      lexicons: lexicons,
      entries: EntryRepository(database),
      notes: NoteRepository(database),
      reminders: ReminderRepository(database),
      settings: settings,
      speech: speech,
      voice: VoiceInputService(),
      images: images,
      scheduler: scheduler,
      // Mỗi ngôn ngữ một nguồn phiên âm. Thêm ngôn ngữ mới = thêm một PhoneticProvider vào danh sách.
      suggestions: OnlineSuggestionService(
        [DictionaryApiProvider(client), JishoProvider(client), PinyinProvider()],
        MyMemoryTranslator(client),
      ),
      planner: ReviewPlanner(),
      sync: SyncService(SyncRepository(database), client),
      session: session,
    );
  }
}
