import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alarm bildirimi uygulamayı açtığında gösterilecek bilgi
class AlarmRequest {
  final int reminderId; // -1 = test alarmı
  final int notificationId;
  final bool alarm;
  final String title;
  final String body;

  /// true: uygulama kapalıyken bu alarm yüzünden açıldı
  final bool cold;

  AlarmRequest({
    required this.reminderId,
    required this.notificationId,
    required this.alarm,
    required this.title,
    required this.body,
    required this.cold,
  });
}

class AlarmRequestNotifier extends Notifier<AlarmRequest?> {
  @override
  AlarmRequest? build() => null;

  void set(AlarmRequest r) => state = r;
  void clear() => state = null;
}

final alarmRequestProvider =
    NotifierProvider<AlarmRequestNotifier, AlarmRequest?>(
        AlarmRequestNotifier.new);