import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bildirim başlığında kişinin adı görünsün mü (birden fazla profil varsa)
class ShowProfileInNotificationNotifier extends Notifier<bool> {
  static const _key = 'show_profile_in_notification';

  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final showProfileInNotificationProvider =
    NotifierProvider<ShowProfileInNotificationNotifier, bool>(
        ShowProfileInNotificationNotifier.new);

/// main.dart açılışta kayıtlı değerle doldurur
final initialOnboardingDoneProvider = Provider<bool>((ref) => false);

class OnboardingDoneNotifier extends Notifier<bool> {
  static const _key = 'onboarding_done';

  @override
  bool build() => ref.read(initialOnboardingDoneProvider);

  Future<void> complete() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final onboardingDoneProvider =
    NotifierProvider<OnboardingDoneNotifier, bool>(OnboardingDoneNotifier.new);