import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UiMode { standard, large }

class UiModeNotifier extends Notifier<UiMode> {
  static const _key = 'ui_mode';

  @override
  UiMode build() {
    _load();
    return UiMode.standard;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'large') state = UiMode.large;
  }

  Future<void> set(UiMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final uiModeProvider =
    NotifierProvider<UiModeNotifier, UiMode>(UiModeNotifier.new);