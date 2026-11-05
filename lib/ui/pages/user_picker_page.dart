import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';

/// Màn hình "Ai đang học nào?": chọn, thêm hoặc xoá bé.
class UserPickerPage extends StatelessWidget {
  const UserPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => UserPickerViewModel(
        c.read<UserRepository>(),
        c.read<ReminderRepository>(),
        c.read<ReminderScheduler>(),
        c.read<AppSession>(),
      )..load(),
      child: const _UserPickerView(),
    );
  }
}

class _UserPickerView extends StatelessWidget {
  const _UserPickerView();

  Future<void> _add(BuildContext context, UserPickerViewModel vm) async {
    final name = await promptText(context, 'Bé tên gì nhỉ?', hint: 'Nhập tên của bé');
    if (name == null || !context.mounted) return;
    final emoji = await chooseOne<String>(context, 'Chọn hình đại diện', Palette.emojis, (e) => e) ??
        Palette.emojis.first;
    await vm.add(name, emoji);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserPickerViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Hapy 🎈',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Palette.primary)),
              const Text('Ai đang học nào?', style: TextStyle(fontSize: 22, color: Palette.ink)),
              const SizedBox(height: 12),
              Expanded(
                child: vm.loading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.users.isEmpty
                        ? const Center(
                            child: Text('Chưa có bé nào.\nBấm "Thêm bé" để bắt đầu nhé! 🌟',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 20)))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
                            itemCount: vm.users.length,
                            itemBuilder: (_, i) {
                              final u = vm.users[i];
                              return Card(
                                color: Color(u.colorValue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () => vm.select(u),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(u.emoji, style: const TextStyle(fontSize: 54)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(u.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 22, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            final ok = await confirm(context, 'Xoá bé?',
                                                'Xoá "${u.name}" cùng toàn bộ từ vựng, ghi chú và nhắc việc?');
                                            if (ok) await vm.remove(u);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                  onPressed: () => _add(context, vm),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm bé', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
