import 'package:flutter/material.dart';

// Helpers for showing a small colored "logo" avatar for a startup based on
// its name, since this project doesn't collect an actual logo image.
// Both functions are deterministic (based on the name), so the same
// startup always gets the same initials + color everywhere in the app,
// instead of a random color changing every time the screen rebuilds.

// A small fixed palette so avatars stay visually distinct but on-brand.
const List<Color> _avatarPalette = [
  Color(0xFF1F2937),
  Color(0xFF4F46E5),
  Color(0xFF312E81),
  Color(0xFF0F766E),
  Color(0xFFB91C1C),
  Color(0xFF7C3AED),
];

/// Builds 1-2 letter initials from a startup name, e.g. "TechNova" -> "T",
/// "Growth Co" -> "GC".
String initialsFromName(String name) {
  final words =
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
}

/// Picks a color from the fixed palette above based on the name, so the
/// same startup always shows up in the same color.
Color colorFromName(String name) {
  final index = name.hashCode.abs() % _avatarPalette.length;
  return _avatarPalette[index];
}
