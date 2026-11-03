import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/locale_provider.dart';
import '../core/time_utils.dart';
import '../notifications/notification_service.dart';
import 'database.dart';
import 'dart:ui' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/profile_colors.dart';
import '../core/settings_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Bugünün anahtarı. Gece yarısı kendini yeniler, liste yeni güne geçer.
final todayKeyProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(
    tomorrow.difference(now) + const Duration(seconds: 1),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
  return dayKeyOf(now);
});

// ---------- Profiller ----------

final profilesProvider = StreamProvider<List<Profile>>((ref) {
  return ref.watch(databaseProvider).watchProfiles();
});

/// Uygulama açılışında main.dart bunu kayıtlı değerle doldurur
final initialProfileIdProvider = Provider<int?>((ref) => null);

class SelectedProfileNotifier extends Notifier<int?> {
  static const _key = 'selected_profile';

  @override
  int? build() => ref.read(initialProfileIdProvider);

  void set(int id) {
    state = id;
    SharedPreferences.getInstance().then((p) => p.setInt(_key, id));
  }
}

final selectedProfileProvider =
    NotifierProvider<SelectedProfileNotifier, int?>(SelectedProfileNotifier.new);

/// Seçili profil geçerli değilse (silindi, henüz seçilmedi) ilk profile düşer
final activeProfileIdProvider = Provider<int?>((ref) {
  final profiles = ref.watch(profilesProvider).value;
  if (profiles == null || profiles.isEmpty) return null;
  final selected = ref.watch(selectedProfileProvider);
  return profiles.any((p) => p.id == selected) ? selected : profiles.first.id;
});

/// Aktif profilin rengi: tema bunu kullanır
final activeColorProvider = Provider<Color>((ref) {
  final profiles = ref.watch(profilesProvider).value;
  final id = ref.watch(activeProfileIdProvider);
  final match = profiles?.where((p) => p.id == id).firstOrNull;
  return Color(match?.colorValue ?? profileColors.first);
});

// ---------- Takvim ----------

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void set(DateTime d) => state = DateTime(d.year, d.month, d.day);
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Seçili profilin, seçili gündeki dozları
final selectedDosesProvider = StreamProvider<List<DoseItem>>((ref) {
  final db = ref.watch(databaseProvider);
  final date = ref.watch(selectedDateProvider);
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return const Stream.empty();
  return db.watchDoses(dayKeyOf(date), profileId);
});

// ---------- Bildirimler ----------

final schedulesProvider = StreamProvider<List<ScheduleItem>>((ref) {
  return ref.watch(databaseProvider).watchSchedules();
});

/// İlaç/profil/dil değişince bildirimleri otomatik yeniden planlar
final notificationSyncProvider = Provider<void>((ref) {
  void sync() {
    final locale = ref.read(localeProvider);
    final items = ref.read(schedulesProvider).value;
    final profiles = ref.read(profilesProvider).value;
    if (items == null || profiles == null) return;
    NotificationService.instance.reschedule(
      items,
      locale,
      showProfile:
          profiles.length > 1 && ref.read(showProfileInNotificationProvider),
    );
  }

  ref.listen(schedulesProvider, (_, __) => sync(), fireImmediately: true);
  ref.listen(profilesProvider, (_, __) => sync());
  ref.listen(localeProvider, (_, __) => sync());
  ref.listen(showProfileInNotificationProvider, (_, __) => sync());
});