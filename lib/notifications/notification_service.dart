import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/profile_utils.dart';
import '../core/time_utils.dart';
import '../data/database.dart';
import '../features/alarm/alarm_request.dart';
import '../l10n/app_localizations.dart';

/// Bildirimdeki "Aldım"/"Ertele" düğmeleri uygulama kapalıyken de bunu çağırır.
/// Ayrı bir izolatta çalışır, bu yüzden üst düzey ve işaretli olmalı.
@pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse r) async {
  debugPrint('MEDTRACKER bg handler: action=${r.actionId} id=${r.id}');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    // Önce sesi durdur: sonraki adımlar hata verse bile alarm susar
    final id = r.id;
    if (id != null && (r.actionId == 'taken' || r.actionId == 'snooze')) {
      await FlutterLocalNotificationsPlugin().cancel(id: id);
    }

    await NotificationService.instance.handleInBackground(r);
    debugPrint('MEDTRACKER bg handler: done');
  } catch (e, st) {
    debugPrint('MEDTRACKER bg handler error: $e\n$st');
  }
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Locale? _locale;
  Future<void> _queue = Future.value();

  /// Ana izolatta "Aldım" için (main.dart'ta bağlanır)
  Future<void> Function(int reminderId)? onTaken;

  /// Alarm/bildirime dokunulunca alarm ekranını açmak için (main.dart'ta bağlanır)
  void Function(AlarmRequest request)? onOpened;

  static const _channelId = 'medication_reminders';
  static const _alarmChannelId = 'medication_alarms';

  // Bildirim kimlik aralıkları (birbirine çarpmasın diye)
  //   haftalık:  reminderId * 100 + (0 = her gün, 1..7 = gün)
  //   tarihli:   1_000_000 + reminderId * 100 + gün farkı (0..59)
  //   test:      2_999_999
  //   erteleme:  3_000_000 + reminderId
  static const _datedBase = 1000000;
  static const _testId = 2999999;
  static const _snoozeBase = 3000000;
  static const _snoozeMinutes = 10;
  static const _datedWindowDays = 60;

  Future<void> _setup() async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    final dynamic info = await FlutterTimezone.getLocalTimezone();
    final String zoneName = info is String ? info : info.identifier as String;
    tz.setLocalLocation(tz.getLocation(zoneName));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) => _handle(r),
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
    _ready = true;
  }

  Future<void> init() async {
    if (kIsWeb) return;
    await _setup();

    // Uygulama kapalıyken bildirime dokunularak/alarm ile açıldıysa
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final r = launch!.notificationResponse;
      if (r != null) await _handle(r, cold: true);
    }
  }

  /// Arka plan izolatında çağrılır
  Future<void> handleInBackground(NotificationResponse r) async {
    await _setup();
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    _locale = code == null ? null : Locale(code);
    await _handle(r);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> requestPermissions() async {
    if (!_ready) return;
    await _android?.requestNotificationsPermission();
    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    if (!canExact) await _android?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Her açılışta çağrılır: sadece bildirim izni
  Future<void> requestNotificationPermissionOnly() async {
    if (!_ready) return;
    await _android?.requestNotificationsPermission();
  }

  Future<void> ensureAlarmPermissions() async {
    if (!_ready) return;
    await _android?.requestFullScreenIntentPermission();
  }

  Future<void> cancelNotification(int id) async {
    if (!_ready || id < 0) return;
    await _plugin.cancel(id: id);
  }

  Future<AppLocalizations> _l10n(Locale? chosen) {
    final wanted = chosen ?? PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales
        .any((l) => l.languageCode == wanted.languageCode);
    return AppLocalizations.delegate
        .load(supported ? Locale(wanted.languageCode) : const Locale('en'));
  }

  NotificationDetails _details(AppLocalizations l10n, {required bool alarm}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        alarm ? _alarmChannelId : _channelId,
        alarm ? l10n.alarmChannelName : l10n.channelName,
        channelDescription:
            alarm ? l10n.alarmChannelDescription : l10n.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: alarm
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        fullScreenIntent: alarm,
        audioAttributesUsage: alarm
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        sound: alarm
            ? const UriAndroidNotificationSound(
                'content://settings/system/alarm_alert')
            : null,
        additionalFlags: alarm ? Int32List.fromList(<int>[4]) : null,
        timeoutAfter: alarm ? 120000 : null,
        enableVibration: true,
        // showsUserInterface: false -> düğmeler uygulamayı açmadan arka planda çalışır
        actions: [
          AndroidNotificationAction('taken', l10n.iTookIt,
              showsUserInterface: false, cancelNotification: true),
          AndroidNotificationAction('snooze', l10n.snooze10,
              showsUserInterface: false, cancelNotification: true),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );
  }

  Future<AndroidScheduleMode> _mode() async {
    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  String _payload(int reminderId, bool alarm, String title, String body) =>
      jsonEncode(
          {'id': reminderId, 'alarm': alarm, 'title': title, 'body': body});

  /// Tüm planı baştan kurar. İstekler sıraya girer.
  Future<void> reschedule(
    List<ScheduleItem> items,
    Locale? locale, {
    required bool showProfile,
  }) {
    _queue = _queue
        .then((_) => _reschedule(items, locale, showProfile))
        .catchError((Object e) {
      debugPrint('reschedule failed: $e');
    });
    return _queue;
  }

  Future<void> _reschedule(
    List<ScheduleItem> items,
    Locale? locale,
    bool showProfile,
  ) async {
    if (!_ready) return;
    _locale = locale;
    final l10n = await _l10n(locale);

    // Bekleyen ertelenmiş (snooze) bildirimleri silme, gerisini temizle
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id < _snoozeBase) await _plugin.cancel(id: p.id);
    }

    final mode = await _mode();
    final now = tz.TZDateTime.now(tz.local);
    final todayKey = dayKeyOf(DateTime(now.year, now.month, now.day));

    for (final item in items) {
      final h = item.minuteOfDay ~/ 60;
      final m = item.minuteOfDay % 60;
      final title = showProfile
          ? l10n.reminderTitleFor(
              profileLabel(l10n, item.profileName), item.name)
          : l10n.reminderTitle(item.name);
      final body = doseLine(item.minuteOfDay, item.dose);
      final details = _details(l10n, alarm: item.useAlarm);
      final payload = _payload(item.reminderId, item.useAlarm, title, body);

      final dated = item.endDay != null || item.startDay > todayKey;

      if (dated) {
        for (var offset = 0; offset < _datedWindowDays; offset++) {
          final day = DateTime(now.year, now.month, now.day + offset);
          final key = dayKeyOf(day);
          if (item.endDay != null && key > item.endDay!) break;
          if (key < item.startDay) continue;
          if (!maskHasDay(item.daysMask, day.weekday)) continue;

          final when =
              tz.TZDateTime(tz.local, day.year, day.month, day.day, h, m);
          if (!when.isAfter(now)) continue;

          await _plugin.zonedSchedule(
            id: _datedBase + item.reminderId * 100 + offset,
            title: title,
            body: body,
            scheduledDate: when,
            notificationDetails: details,
            androidScheduleMode: mode,
            payload: payload,
          );
        }
      } else if (item.daysMask == 127) {
        var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
        if (!when.isAfter(now)) {
          when =
              tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, h, m);
        }
        await _plugin.zonedSchedule(
          id: item.reminderId * 100,
          title: title,
          body: body,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } else {
        for (var wd = 1; wd <= 7; wd++) {
          if (!maskHasDay(item.daysMask, wd)) continue;
          tz.TZDateTime? when;
          for (var i = 0; i < 8; i++) {
            final c = tz.TZDateTime(
                tz.local, now.year, now.month, now.day + i, h, m);
            if (c.weekday == wd && c.isAfter(now)) {
              when = c;
              break;
            }
          }
          if (when == null) continue;
          await _plugin.zonedSchedule(
            id: item.reminderId * 100 + wd,
            title: title,
            body: body,
            scheduledDate: when,
            notificationDetails: details,
            androidScheduleMode: mode,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        }
      }
    }
  }

  /// Test: 10 saniye sonra bildirim ya da alarm
  Future<void> scheduleTest(Locale? locale, {bool alarm = false}) async {
    if (!_ready) return;
    _locale = locale;
    final l10n = await _l10n(locale);
    await _plugin.zonedSchedule(
      id: _testId,
      title: l10n.testTitle,
      body: l10n.testBody,
      scheduledDate:
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails: _details(l10n, alarm: alarm),
      androidScheduleMode: await _mode(),
      payload: _payload(-1, alarm, l10n.testTitle, l10n.testBody),
    );
  }

  /// "Aldım": ana izolatta uygulamanın veritabanı, arka planda kendi bağlantımız
  Future<void> _markTaken(int reminderId) async {
    final cb = onTaken;
    if (cb != null) {
      await cb(reminderId);
      return;
    }
    final db = AppDatabase();
    try {
      await db.markTaken(reminderId, dayKeyOf(DateTime.now()));
    } finally {
      await db.close();
    }
  }

  Future<void> _handle(NotificationResponse r, {bool cold = false}) async {
    final raw = r.payload;
    if (raw == null) return;
    final Map<String, dynamic> p;
    try {
      p = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final id = p['id'] as int; // -1 = test bildirimi

    switch (r.actionId) {
      case 'taken':
        if (id >= 0) {
          await _plugin.cancel(id: _snoozeBase + id);
          await _markTaken(id);
        }
      case 'snooze':
        await _snoozeMap(p);
      default:
        // Bildirime ya da tam ekran alarma dokunuldu/alarm uygulamayı açtı
        if (p['alarm'] == true) {
          onOpened?.call(AlarmRequest(
            reminderId: id,
            notificationId: r.id ?? -1,
            alarm: true,
            title: p['title'] as String,
            body: p['body'] as String,
            cold: cold,
          ));
        }
    }
  }

  /// Alarm ekranından erteleme
  Future<void> snooze(AlarmRequest req) => _snoozeMap({
        'id': req.reminderId,
        'alarm': req.alarm,
        'title': req.title,
        'body': req.body,
      });

  Future<void> _snoozeMap(Map<String, dynamic> p) async {
    final l10n = await _l10n(_locale);
    final id = p['id'] as int;
    await _plugin.zonedSchedule(
      id: _snoozeBase + (id < 0 ? 0 : id),
      title: p['title'] as String,
      body: p['body'] as String,
      scheduledDate: tz.TZDateTime.now(tz.local)
          .add(const Duration(minutes: _snoozeMinutes)),
      notificationDetails: _details(l10n, alarm: p['alarm'] as bool),
      androidScheduleMode: await _mode(),
      payload: jsonEncode(p),
    );
  }
}