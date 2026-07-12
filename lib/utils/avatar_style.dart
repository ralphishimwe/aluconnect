import 'package:flutter/material.dart';

const List<Color> _avatarPalette = [
  Color(0xFF1F2937),
  Color(0xFF4F46E5),
  Color(0xFF312E81),
  Color(0xFF0F766E),
  Color(0xFFB91C1C),
  Color(0xFF7C3AED),
];

String initialsFromName(String name) {
  final words =
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
}

Color colorFromName(String name) {
  final index = name.hashCode.abs() % _avatarPalette.length;
  return _avatarPalette[index];
}
