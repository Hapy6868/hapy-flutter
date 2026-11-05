import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';
import '../widgets/lexicon_flow.dart';

/// Tab "Hồ sơ": đổi bé, quản lý từ điển, đồng bộ server, thử giọng đọc.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => ProfileViewModel(c.read<SettingsRepository>(), c.read<SyncService>(), c.read<SpeechService>()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Widget _card(Color color, List<Widget> children) => Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final session = context.watch<AppSession>();
    final user = session.user;
    final lexicon = session.lexicon;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('🙂 Hồ sơ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.sun,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(Palette.cards[0], [
            const Text('Bé đang học', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(user == null ? 'Chưa chọn bé' : '${user.emoji} ${user.name}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            FilledButton(onPressed: session.signOut, child: const Text('🔁 Đổi bé')),
          ]),
          _card(Palette.cards[1], [
            const Text('Từ điển đang dùng', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(lexicon?.label ?? 'Chưa có từ điển', style: const TextStyle(fontSize: 20)),
            FilledButton(onPressed: () => LexiconFlow.choose(context), child: const Text('🔄 Chọn từ điển khác')),
            FilledButton(onPressed: () => LexiconFlow.create(context), child: const Text('➕ Tạo từ điển mới')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFA1887F)),
              onPressed: () => LexiconFlow.deleteCurrent(context),
              child: const Text('🗑 Xoá từ điển này'),
            ),
          ]),
          _card(Palette.cards[2], [
            const Text('☁️ Đồng bộ lên server', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(vm.syncUrl.isEmpty ? '(chưa đặt địa chỉ)' : vm.syncUrl,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            FilledButton(
              onPressed: () async {
                final url = await promptText(context, 'Địa chỉ server',
                    hint: 'https://example.com/api/sync', initial: vm.syncUrl);
                if (url != null) await vm.setUrl(url);
              },
              child: const Text('Đặt địa chỉ server'),
            ),
            FilledButton(onPressed: vm.busy ? null : vm.syncNow, child: const Text('Đồng bộ ngay')),
            if (vm.status.isNotEmpty) Text(vm.status, style: const TextStyle(fontSize: 14)),
          ]),
          _card(Palette.cards[3], [
            const Text('Giọng đọc', style: TextStyle(fontWeight: FontWeight.bold)),
            FilledButton(onPressed: vm.testVoice, child: const Text('🔊 Thử giọng đọc')),
            const Text('iPhone: nhớ tắt chế độ im lặng và tăng âm lượng.', style: TextStyle(fontSize: 13)),
          ]),
        ],
      ),
    );
  }
}
