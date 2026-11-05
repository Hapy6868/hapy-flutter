import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../state/state.dart';
import '../widgets/date_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_view.dart';

/// Tab "Nhật ký": ghi chú nội dung học trong ngày.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => NotesViewModel(c.read<AppSession>(), c.read<NoteRepository>())..load(),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  Future<void> _add(BuildContext context, NotesViewModel vm) async {
    final content = await promptText(context, 'Hôm nay bé học gì?', hint: 'Ghi lại nội dung đã học');
    if (content == null || !context.mounted) return;
    final emoji = await chooseOne<String>(context, 'Chọn biểu tượng', Palette.emojis, (e) => e) ?? '📒';
    await vm.add(content, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotesViewModel>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('📒 Nhật ký học', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.sun,
        actions: const [DateButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, vm),
        icon: const Icon(Icons.add),
        label: const Text('Ghi chú'),
      ),
      body: vm.items.isEmpty
          ? const EmptyView('Chưa có ghi chú cho ngày này ✨\nBấm "Ghi chú" để ghi lại bài học nhé!')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: vm.items.length,
              itemBuilder: (_, i) {
                final n = vm.items[i];
                return Card(
                  color: Palette.card(i + 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Text(n.emoji, style: const TextStyle(fontSize: 34)),
                    title: Text(n.content, style: const TextStyle(fontSize: 18)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await confirm(context, 'Xoá ghi chú?', n.content)) await vm.remove(n);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
