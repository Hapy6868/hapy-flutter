import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
        ),
      );
}
