import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Único interruptor claro/oscuro de toda la app.
class ThemeController extends ValueNotifier<bool> {
  ThemeController._() : super(true);
  static final ThemeController instance = ThemeController._();

  static const _key = 'is_dark_mode';

  bool get isDark => value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_key) ?? true;
  }

  Future<void> set(bool dark) async {
    if (value == dark) return;
    value = dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }

  Future<void> toggle() => set(!value);
}
