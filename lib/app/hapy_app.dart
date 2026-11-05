import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../data/data.dart';
import '../services/services.dart';
import '../state/state.dart';
import '../ui/pages/home_shell.dart';
import '../ui/pages/user_picker_page.dart';
import 'app_dependencies.dart';

class HapyApp extends StatelessWidget {
  const HapyApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSession>.value(value: deps.session),
        Provider<UserRepository>.value(value: deps.users),
        Provider<LexiconRepository>.value(value: deps.lexicons),
        Provider<EntryRepository>.value(value: deps.entries),
        Provider<NoteRepository>.value(value: deps.notes),
        Provider<ReminderRepository>.value(value: deps.reminders),
        Provider<SettingsRepository>.value(value: deps.settings),
        Provider<SpeechService>.value(value: deps.speech),
        Provider<VoiceInputService>.value(value: deps.voice),
        Provider<ReviewPlanner>.value(value: deps.planner),
        Provider<ImageStore>.value(value: deps.images),
        Provider<ReminderScheduler>.value(value: deps.scheduler),
        Provider<SuggestionService>.value(value: deps.suggestions),
        Provider<SyncService>.value(value: deps.sync),
      ],
      child: MaterialApp(
        title: 'Hapy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Palette.primary,
          scaffoldBackgroundColor: Palette.cream,
        ),
        home: const _AppGate(),
      ),
    );
  }
}

/// Chưa chọn bé → màn "Ai đang học nào?"; đã chọn → màn hình chính.
class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return session.user == null ? const UserPickerPage() : const HomeShell();
  }
}
