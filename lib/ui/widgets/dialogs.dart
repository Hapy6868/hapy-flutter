import 'package:flutter/material.dart';

/// Hộp thoại hỏi nội dung. Trả về null nếu hủy hoặc để trống.
Future<String?> promptText(BuildContext context, String title,
    {String hint = '', String initial = ''}) async {
  final ctrl = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('OK')),
      ],
    ),
  );
  return (result == null || result.isEmpty) ? null : result;
}

Future<bool> confirm(BuildContext context, String title, String message) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý')),
      ],
    ),
  );
  return ok ?? false;
}

/// Chọn một mục trong danh sách. Trả về null nếu đóng hộp thoại.
Future<T?> chooseOne<T>(BuildContext context, String title, List<T> options, String Function(T) label) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(title),
      children: [
        for (final o in options)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, o),
            child: Text(label(o), style: const TextStyle(fontSize: 18)),
          ),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
