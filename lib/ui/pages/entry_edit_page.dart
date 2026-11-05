import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';
import '../widgets/thumb.dart';

/// Màn hình nhập / sửa một từ hoặc một câu: gõ hoặc nói, có gợi ý phiên âm và nghĩa theo ngôn ngữ từ điển.
class EntryEditPage extends StatelessWidget {
  const EntryEditPage._();

  /// Tạo trang kèm ViewModel. Gọi từ Navigator: `EntryEditPage.create(existing: e)`.
  static Widget create({VocabEntry? existing}) {
    return ChangeNotifierProvider(
      create: (c) => EntryEditViewModel(
        session: c.read<AppSession>(),
        entries: c.read<EntryRepository>(),
        suggestions: c.read<SuggestionService>(),
        speech: c.read<SpeechService>(),
        voice: c.read<VoiceInputService>(),
        images: c.read<ImageStore>(),
        existing: existing,
      ),
      child: const EntryEditPage._(),
    );
  }

  Widget _card(Color color, List<Widget> children) => Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _suggestionRow(String text, VoidCallback onUse) => Row(
        children: [
          Expanded(child: Text('💡 Gợi ý: $text', style: const TextStyle(fontSize: 14))),
          TextButton(onPressed: onUse, child: const Text('Dùng')),
        ],
      );

  /// Nút micro: đỏ khi đang nghe.
  Widget _mic(EntryEditViewModel vm, VoiceField field) {
    final on = vm.listening == field;
    return IconButton(
      tooltip: on ? 'Dừng nghe' : 'Nói để nhập',
      icon: Icon(on ? Icons.mic : Icons.mic_none, color: on ? Colors.red : Palette.primaryDark),
      onPressed: () => vm.toggleVoice(field),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EntryEditViewModel>();
    final images = context.read<ImageStore>();
    final lang = vm.lang;
    final isJaOrZh = lang.code != 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text('${lang.flag} ${vm.isWord ? 'Từ mới' : 'Câu mới'} • ${lang.title}'),
        backgroundColor: Palette.sun,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(Palette.cards[0], [
            _label(vm.isWord ? 'Từ ${lang.name}' : 'Câu ${lang.name}'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: vm.text,
                    autocorrect: false,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => vm.suggest(),
                    style: TextStyle(fontSize: isJaOrZh ? 22 : 18),
                    decoration: InputDecoration(
                      hintText: vm.isWord ? lang.wordHint : lang.sentenceHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                _mic(vm, VoiceField.text),
                IconButton(icon: const Icon(Icons.volume_up), onPressed: vm.speakText),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                FilledButton(onPressed: vm.busy ? null : vm.suggest, child: const Text('💡 Gợi ý')),
                const SizedBox(width: 8),
                Expanded(
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Tự gợi ý sau khi nói', style: TextStyle(fontSize: 13)),
                    value: vm.autoSuggestAfterVoice,
                    onChanged: (v) => vm.setAutoSuggestAfterVoice(v ?? true),
                  ),
                ),
              ],
            ),
            if (vm.busy) const Padding(padding: EdgeInsets.only(top: 4), child: LinearProgressIndicator()),
            if (vm.hint.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(vm.hint, style: const TextStyle(fontSize: 14, color: Palette.primaryDark)),
              ),
          ]),
          _card(Palette.cards[1], [
            _label(lang.phoneticLabel),
            TextField(
              controller: vm.phonetic,
              decoration: InputDecoration(hintText: lang.phoneticHint, border: const OutlineInputBorder()),
            ),
            if (vm.hasAutoPhonetic) _suggestionRow(vm.autoPhonetic, vm.usePhonetic),
          ]),
          _card(Palette.cards[2], [
            _label('Nghĩa tiếng Việt (tự sửa cho phù hợp)'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: vm.meaning,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        hintText: 'Nghĩa của từ/câu...', border: OutlineInputBorder()),
                  ),
                ),
                _mic(vm, VoiceField.meaning),
              ],
            ),
            if (vm.hasAutoMeaning) _suggestionRow(vm.autoMeaning, vm.useMeaning),
          ]),
          _card(Palette.cards[3], [
            _label('Câu ví dụ (không bắt buộc)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: vm.example, decoration: const InputDecoration(border: OutlineInputBorder())),
                ),
                _mic(vm, VoiceField.example),
              ],
            ),
            const SizedBox(height: 12),
            _label('Ngày học'),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(DateFormat('dd/MM/yyyy').format(vm.studyDate)),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: vm.studyDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) vm.setDate(d);
              },
            ),
            const SizedBox(height: 12),
            _label('Hình minh họa'),
            Row(
              children: [
                OutlinedButton.icon(
                    onPressed: vm.pickImage, icon: const Icon(Icons.image), label: const Text('Chèn ảnh')),
                const SizedBox(width: 8),
                if (vm.imageFile.isNotEmpty) ...[
                  Thumb(file: images.fileOf(vm.imageFile), fallback: '🖼️', size: 48),
                  IconButton(icon: const Icon(Icons.close), onPressed: vm.removeImage),
                ],
              ],
            ),
          ]),
          const SizedBox(height: 4),
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            icon: const Icon(Icons.check),
            label: const Text('Lưu', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              if (await vm.save() && context.mounted) Navigator.pop(context);
            },
          ),
          if (vm.existing != null)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xoá'),
              onPressed: () async {
                if (await confirm(context, 'Xoá?', 'Xoá "${vm.existing!.text}"?')) {
                  await vm.deleteExisting();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }
}
