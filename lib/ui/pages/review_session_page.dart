import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/thumb.dart';

/// Phiên ôn tập: thẻ lớn, tự phát âm, hiện nghĩa theo cấu hình, chấm "nhớ / chưa nhớ".
class ReviewSessionPage extends StatelessWidget {
  const ReviewSessionPage._();

  static Widget create({required List<ReviewCard> cards, required ReviewConfig config}) {
    return ChangeNotifierProvider(
      create: (c) => ReviewSessionViewModel(
        cards: cards,
        config: config,
        speech: c.read<SpeechService>(),
        entries: c.read<EntryRepository>(),
      ),
      child: const ReviewSessionPage._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewSessionViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.finished ? '🎉 Kết quả' : 'Ôn tập ${vm.index + 1}/${vm.total}'),
        backgroundColor: Palette.sun,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: vm.progress),
        ),
      ),
      body: SafeArea(child: vm.finished ? _Summary(vm: vm) : _CardView(vm: vm)),
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({required this.vm});
  final ReviewSessionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final images = context.read<ImageStore>();
    final c = vm.config;
    final card = vm.card;
    final e = card.entry;
    final isSentence = e.text.length > 14;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Card(
              color: Palette.card(vm.index),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(card.language.flag, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      if (images.fileOf(e.image) != null) ...[
                        Thumb(file: images.fileOf(e.image), size: 120),
                        const SizedBox(height: 12),
                      ],
                      Text(e.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isSentence ? 28 : 42, fontWeight: FontWeight.bold)),
                      if (c.showPhonetic && e.phonetic.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(e.phonetic,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Palette.primaryDark, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 20),
                      if (vm.revealed) ...[
                        Text(e.meaning.isEmpty ? '(chưa có nghĩa)' : e.meaning,
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 26)),
                        if (e.example.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text('“${e.example}”',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                          ),
                      ] else ...[
                        FilledButton.tonal(onPressed: vm.reveal, child: const Text('👁 Xem nghĩa')),
                        if (c.meaningMode == MeaningMode.auto)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Nghĩa sẽ tự hiện sau ${c.meaningDelaySeconds} giây...',
                                style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(iconSize: 32, icon: const Icon(Icons.skip_previous), onPressed: vm.previous),
              IconButton.filledTonal(
                  iconSize: 36, icon: const Icon(Icons.volume_up), onPressed: vm.speakCurrent),
              if (c.autoAdvance)
                IconButton.filledTonal(
                  iconSize: 36,
                  icon: Icon(vm.paused ? Icons.play_arrow : Icons.pause),
                  onPressed: vm.togglePause,
                ),
              IconButton(iconSize: 32, icon: const Icon(Icons.skip_next), onPressed: vm.next),
            ],
          ),
          if (!c.autoAdvance) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFA1887F), padding: const EdgeInsets.all(16)),
                    onPressed: () => vm.answer(false),
                    child: const Text('😕 Chưa nhớ', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
                    onPressed: () => vm.answer(true),
                    child: const Text('😀 Đã nhớ', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.vm});
  final ReviewSessionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final answered = vm.config.autoAdvance == false;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
          Text(
            answered ? 'Bé nhớ ${vm.remembered}/${vm.total} thẻ!' : 'Đã xem hết ${vm.total} thẻ!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (vm.forgotten.isNotEmpty) ...[
            const Text('Những thẻ chưa nhớ:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: [
                  for (final f in vm.forgotten)
                    ListTile(
                      leading: Text(f.language.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(f.entry.text),
                      subtitle: Text(f.entry.meaning),
                    ),
                ],
              ),
            ),
            FilledButton(onPressed: vm.restartWithForgotten, child: const Text('🔁 Ôn lại các thẻ chưa nhớ')),
          ] else
            const Spacer(),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Xong')),
        ],
      ),
    );
  }
}
