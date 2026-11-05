import 'dart:io';

import 'package:flutter/material.dart';

/// Ảnh vuông bo góc; nếu chưa có ảnh thì hiện emoji.
class Thumb extends StatelessWidget {
  const Thumb({super.key, this.file, this.fallback = '🔤', this.size = 64});

  final File? file;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(file!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white,
      child: Text(fallback, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
