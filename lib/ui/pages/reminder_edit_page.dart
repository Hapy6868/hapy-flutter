import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../data/data.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../state/state.dart';
import '../widgets/dialogs.dart';
import '../widgets/emoji_picker.dart';

/// Màn hình tạo nhắc việc (giờ + lặp một lần / hằng ngày / hằng tuần).
class ReminderEditPage extends StatelessWidget {
  const ReminderEditPage._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (c) => ReminderEditViewModel(
        c.read<AppSession>(),
        c.read<ReminderRepository>(),
        c.read<ReminderScheduler>(),
      ),
      child: const ReminderEditPage._(),
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

  Widget _label(String s) =>
      Padding(padding: const EdgeInsets.only(top: 8, bottom: 4), child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)));

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReminderEditViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('⏰ Tạo nhắc việc'), backgroundColor: Palette.sun),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(Palette.cards[0], [
            _label('Biểu tượng'),
            EmojiPicker(
              options: ReminderEditViewModel.emojiOptions,
              value: vm.emoji,
              onChanged: (e) => vm.update(() => vm.emoji = e),
            ),
            _label('Nội dung nhắc'),
            TextField(controller: vm.title, decoration: const InputDecoration(border: OutlineInputBorder())),
          ]),
          _card(Palette.cards[1], [
            _label('Giờ nhắc'),
            OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(vm.time.format(context), style: const TextStyle(fontSize: 20)),
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: vm.time);
                if (t != null) vm.update(() => vm.time = t);
              },
            ),
            _label('Lặp lại'),
            DropdownButtonFormField<RepeatKind>(
              value: vm.repeat,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: RepeatKind.once, child: Text('Một lần (chọn ngày)')),
                DropdownMenuItem(value: RepeatKind.daily, child: Text('Hằng ngày')),
                DropdownMenuItem(value: RepeatKind.weekly, child: Text('Hằng tuần')),
              ],
              onChanged: (v) => vm.update(() => vm.repeat = v ?? RepeatKind.daily),
            ),
            if (vm.repeat == RepeatKind.once) ...[
              _label('Ngày'),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(DateFormat('dd/MM/yyyy').format(vm.date)),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: vm.date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) vm.update(() => vm.date = d);
                },
              ),
            ],
            if (vm.repeat == RepeatKind.weekly) ...[
              _label('Thứ trong tuần'),
              DropdownButtonFormField<int>(
                value: vm.weekday,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (var i = 1; i <= 7; i++) DropdownMenuItem(value: i, child: Text(weekdayNames[i - 1])),
                ],
                onChanged: (v) => vm.update(() => vm.weekday = v ?? 1),
              ),
            ],
          ]),
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            icon: const Icon(Icons.check),
            label: const Text('Lưu nhắc việc', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              final ok = await vm.save();
              if (!context.mounted) return;
              if (vm.permissionDenied) {
                showSnack(context, 'Chưa bật thông báo: vào Cài đặt → Thông báo → Hapy để cho phép nhé.');
              }
              if (ok) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
