import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/time_utils.dart';
import 'database.dart';
import '../notifications/notification_service.dart';
import '../core/locale_provider.dart';
import 'dart:async';

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

final todayDosesProvider = StreamProvider<List<DoseItem>>((ref) {
  final db = ref.watch(databaseProvider);
  final key = ref.watch(todayKeyProvider);
  return db.watchDoses(key);
});

final schedulesProvider = StreamProvider<List<ScheduleItem>>((ref) {
  return ref.watch(databaseProvider).watchSchedules();
});

/// İlaç eklenince/silinince bildirimleri otomatik yeniden planlar
final notificationSyncProvider = Provider<void>((ref) {
  void sync() {
    final locale = ref.read(localeProvider);
    ref.read(schedulesProvider).whenData(
          (items) => NotificationService.instance.reschedule(items, locale),
        );
  }

  ref.listen(schedulesProvider, (_, __) => sync(), fireImmediately: true);
  ref.listen(localeProvider, (_, __) => sync());
});

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

/// Takvimde seçili günün dozları (büyük mod hâlâ todayDosesProvider kullanır)
final selectedDosesProvider = StreamProvider<List<DoseItem>>((ref) {
  final db = ref.watch(databaseProvider);
  final date = ref.watch(selectedDateProvider);
  return db.watchDoses(dayKeyOf(date));
});