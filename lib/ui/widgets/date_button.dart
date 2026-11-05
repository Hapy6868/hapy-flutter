import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/state.dart';

/// Nút chọn ngày ở góc thanh tiêu đề (dùng chung cho tab Từ điển và Nhật ký).
class DateButton extends StatelessWidget {
  const DateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return TextButton.icon(
      icon: const Icon(Icons.calendar_month),
      label: Text(DateFormat('dd/MM/yyyy').format(session.date)),
      onPressed: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: session.date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (d != null) session.setDate(d);
      },
    );
  }
}
