import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';
import 'review_session_page.dart';

/// Chọn cách ôn tập rồi để app TỰ ĐỘNG chọn từ/câu.
class ReviewSetupPage extends StatelessWidget {
  const ReviewSetupPage._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (c) => ReviewSetupViewModel(
        c.read<AppSession>(),
        c.read<EntryRepository>(),
        c.read<LexiconRepository>(),
        c.read<ReviewPlanner>(),
      ),
      child: const ReviewSetupPage._(),
    );
  }

  Widget _section(Color color, String title, List<Widget> children) => Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );

  Widget _chips<T>(List<T> values, T selected, String Function(T) label, ValueChanged<T> onSelect) => Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final v in values)
            ChoiceChip(label: Text(label(v)), selected: v == selected, onSelected: (_) => onSelect(v)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewSetupViewModel>();
    final c = vm.config;
    final lexicon = vm.currentLexicon;

    return Scaffold(
      appBar: AppBar(title: const Text('🎯 Ôn tập'), backgroundColor: Palette.sun),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(Palette.cards[0], 'Lấy từ ở đâu?', [
            _chips<ReviewScope>(
              ReviewScope.values,
              c.scope,
              (s) => s == ReviewScope.currentLexicon
                  ? (lexicon == null ? 'Từ điển đang chọn' : '${lexicon.emoji} ${lexicon.name}')
                  : 'Tất cả từ điển của bé',
              (s) => vm.update(() => c.scope = s),
            ),
            const SizedBox(height: 8),
            const Text('Từ đã học trong:'),
            _chips<ReviewRange>(
              ReviewRange.values,
              c.range,
              (r) => switch (r) {
                ReviewRange.today => 'Hôm nay',
                ReviewRange.week => '7 ngày gần đây',
                ReviewRange.all => 'Tất cả',
              },
              (r) => vm.update(() => c.range = r),
            ),
          ]),
          _section(Palette.cards[1], 'Tự động chọn mấy từ?', [
            _chips<int>([5, 10, 20, 30], c.count, (n) => '$n', (n) => vm.update(() => c.count = n)),
            const SizedBox(height: 8),
            const Text('Ưu tiên:'),
            _chips<ReviewFocus>(
              ReviewFocus.values,
              c.focus,
              (f) => switch (f) {
                ReviewFocus.auto => '🎲 Tự động',
                ReviewFocus.hard => '😕 Từ khó nhớ',
                ReviewFocus.newest => '🆕 Mới thêm',
              },
              (f) => vm.update(() => c.focus = f),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Tự động: ưu tiên từ chưa ôn, từ khó và từ lâu chưa gặp, xen ngẫu nhiên.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ]),
          _section(Palette.cards[2], 'Phát âm và hiển thị', [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('🔊 Tự động phát âm'),
              value: c.autoSpeak,
              onChanged: (v) => vm.update(() => c.autoSpeak = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hiện phiên âm / cách đọc'),
              value: c.showPhonetic,
              onChanged: (v) => vm.update(() => c.showPhonetic = v),
            ),
            const Text('Nghĩa tiếng Việt:'),
            _chips<MeaningMode>(
              MeaningMode.values,
              c.meaningMode,
              (m) => switch (m) {
                MeaningMode.tap => '🙈 Chạm mới xem',
                MeaningMode.auto => '⏱ Tự hiện sau ${c.meaningDelaySeconds}s',
                MeaningMode.always => '👁 Luôn hiện',
              },
              (m) => vm.update(() => c.meaningMode = m),
            ),
          ]),
          _section(Palette.cards[3], 'Chế độ tự chạy', [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('▶️ Tự đọc và tự sang thẻ tiếp'),
              subtitle: const Text('Như trình chiếu: nghe từ, xem nghĩa (nếu cho phép), rồi tự chuyển.'),
              value: c.autoAdvance,
              onChanged: (v) => vm.update(() => c.autoAdvance = v),
            ),
          ]),
          const SizedBox(height: 4),
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            icon: vm.busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu ôn tập', style: TextStyle(fontSize: 20)),
            onPressed: vm.busy
                ? null
                : () async {
                    final cards = await vm.buildCards();
                    if (!context.mounted) return;
                    if (cards.isEmpty) {
                      showSnack(context, vm.message);
                      return;
                    }
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => ReviewSessionPage.create(cards: cards, config: vm.config)),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
