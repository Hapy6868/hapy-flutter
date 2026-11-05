import 'package:flutter/material.dart';

/// Màu sắc và emoji dùng chung cho giao diện trẻ em.
class Palette {
  static const cream = Color(0xFFFFF8E1);
  static const sun = Color(0xFFFFCC80);
  static const primary = Color(0xFFFF7043);
  static const primaryDark = Color(0xFFD84315);
  static const ink = Color(0xFF4E342E);

  static const cards = [
    Color(0xFFFFE0B2),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFF8BBD0),
    Color(0xFFE1BEE7),
    Color(0xFFFFF9C4),
  ];

  static const userColors = [0xFFFFCC80, 0xFFA5D6A7, 0xFF90CAF9, 0xFFF48FB1, 0xFFCE93D8, 0xFFFFF59D];

  static const emojis = ['🧒', '👧', '👦', '🦄', '🐶', '🐱', '🐼', '🚀', '🌈', '⭐', '🍎', '🎨'];

  static Color card(int index) => cards[index % cards.length];
}
