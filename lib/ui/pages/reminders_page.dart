import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_view.dart';
import 'reminder_edit_page.dart';

/// Tab "Nhắc việc": danh sách nhắc việc, bật/tắt chuông, thêm, xoá.
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => RemindersViewModel(
        c.read<AppSession>(),
        c.read<ReminderRepository>(),
        c.read<ReminderScheduler>(),
      )..load(),
      child: const _RemindersView(),
    );
  }
}

class _RemindersView extends StatelessWidget {
  const _RemindersView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RemindersViewModel>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('⏰ Nhắc việc', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.sun,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_alarm),
        label: const Text('Nhắc việc'),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReminderEditPage.create()));
          await vm.load();
        },
      ),
      body: vm.items.isEmpty
          ? const EmptyView('Chưa có nhắc việc nào ⏰\nTạo lịch học để không quên nhé!')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: vm.items.length,
              itemBuilder: (_, i) {
                final r = vm.items[i];
                return Card(
                  color: Palette.card(i + 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: Text(r.emoji, style: const TextStyle(fontSize: 32)),
                    title: Text(r.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(describeReminder(r)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Text(r.enabled ? '🔔' : '🔕', style: const TextStyle(fontSize: 24)),
                          onPressed: () => vm.toggle(r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await confirm(context, 'Xoá nhắc việc?', r.title)) await vm.remove(r);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
