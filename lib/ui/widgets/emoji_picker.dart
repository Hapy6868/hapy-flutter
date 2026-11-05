import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  const EmojiPicker({super.key, required this.options, required this.value, required this.onChanged});

  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final e in options)
            ChoiceChip(
              label: Text(e, style: const TextStyle(fontSize: 22)),
              selected: e == value,
              onSelected: (_) => onChanged(e),
            ),
        ],
      );
}
