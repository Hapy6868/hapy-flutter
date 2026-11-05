import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/date_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_view.dart';
import '../widgets/lexicon_flow.dart';
import '../widgets/thumb.dart';
import 'entry_edit_page.dart';
import 'review_setup_page.dart';

/// Tab "Từ điển": danh sách từ/câu của từ điển đang chọn.
class EntriesPage extends StatelessWidget {
  const EntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => EntriesViewModel(c.read<AppSession>(), c.read<EntryRepository>())..load(),
      child: const _EntriesView(),
    );
  }
}

class _EntriesView extends StatelessWidget {
  const _EntriesView();

  Future<void> _edit(BuildContext context, EntriesViewModel vm, [VocabEntry? e]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryEditPage.create(existing: e)));
    await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EntriesViewModel>();
    final images = context.read<ImageStore>();
    final speech = context.read<SpeechService>();
    final lexicon = vm.lexicon;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('📚 Từ điển', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.sun,
        actions: [
          IconButton(
            tooltip: 'Ôn tập',
            icon: const Icon(Icons.school),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ReviewSetupPage.create()))
                .then((_) => vm.load()),
          ),
          const DateButton(),
        ],
      ),
      floatingActionButton: lexicon == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(context, vm),
              icon: const Icon(Icons.add),
              label: Text(lexicon.kind == EntryKind.word ? 'Thêm từ' : 'Thêm câu'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              color: Palette.sun,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lexicon == null ? 'Chưa chọn từ điển' : '${lexicon.emoji} ${lexicon.name} ${lexicon.language.flag}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => LexiconFlow.choose(context),
                      child: const Text('🔄 Đổi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SwitchListTile(
            dense: true,
            title: const Text('Xem tất cả các ngày'),
            value: vm.showAll,
            onChanged: vm.setShowAll,
          ),
          Expanded(
            child: vm.items.isEmpty
                ? EmptyView(lexicon?.kind == EntryKind.sentence
                    ? 'Chưa có câu nào 🌟\nBấm "Thêm câu" nhé!'
                    : 'Chưa có từ nào 🌟\nBấm "Thêm từ" nhé!')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: vm.items.length,
                    itemBuilder: (_, i) {
                      final e = vm.items[i];
                      return Card(
                        color: Palette.card(i),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _edit(context, vm, e),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Thumb(file: images.fileOf(e.image)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.text,
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      if (e.phonetic.isNotEmpty)
                                        Text(e.phonetic,
                                            style: const TextStyle(
                                                color: Palette.primaryDark, fontStyle: FontStyle.italic)),
                                      if (e.meaning.isNotEmpty)
                                        Text(e.meaning, style: const TextStyle(fontSize: 18)),
                                      if (e.example.isNotEmpty)
                                        Text('“${e.example}”',
                                            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                                      if (e.meaningEdited)
                                        const Text('✏️ Nghĩa do bé / phụ huynh chỉnh',
                                            style: TextStyle(fontSize: 12, color: Palette.primaryDark)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.volume_up, color: Colors.deepOrange, size: 30),
                                      onPressed: () => speech.speak(e.text, locale: lexicon?.language.ttsLocale ?? 'en-US'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        if (await confirm(context, 'Xoá?', 'Xoá "${e.text}"?')) {
                                          await vm.remove(e);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
