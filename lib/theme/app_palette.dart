import 'package:flutter/material.dart';

class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get appBar => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get card => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get text => isDark ? Colors.white : Colors.black87;
  Color get subtleText => isDark ? Colors.white70 : Colors.black54;
  Color get mutedText => isDark ? Colors.white54 : Colors.black45;
  Color get accent => isDark ? Colors.cyanAccent : Colors.blueAccent;
  Color get fab => isDark ? const Color(0xFF334155) : Colors.white;
  Color get cardBorder => isDark ? Colors.white12 : Colors.black12;
  Color get divider => isDark ? Colors.white24 : Colors.black12;
}
