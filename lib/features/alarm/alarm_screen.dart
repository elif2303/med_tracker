import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/time_utils.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import 'alarm_request.dart';

class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key, required this.request});
  final AlarmRequest request;

  void _finish(BuildContext context, WidgetRef ref) {
    ref.read(alarmRequestProvider.notifier).clear();
    if (request.cold) {
      // Alarm yüzünden açıldıysa kilit ekranına/önceki ekrana dön
      SystemNavigator.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _done(BuildContext context, WidgetRef ref) async {
    final service = NotificationService.instance;
    await service.cancelNotification(request.notificationId);
    if (request.reminderId >= 0) {
      await ref
          .read(databaseProvider)
          .markTaken(request.reminderId, dayKeyOf(DateTime.now()));
    }
    if (context.mounted) _finish(context, ref);
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    final service = NotificationService.instance;
    await service.cancelNotification(request.notificationId);
    await service.snooze(request);
    if (context.mounted) _finish(context, ref);
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    await NotificationService.instance
        .cancelNotification(request.notificationId);
    if (context.mounted) _finish(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context, ref);
      },
      child: Scaffold(
        backgroundColor: scheme.primaryContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(Icons.alarm,
                    size: 96, color: scheme.onPrimaryContainer),
                const SizedBox(height: 24),
                Text(
                  request.title,
                  textAlign: TextAlign.center,
                  style: text.headlineMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  request.body,
                  textAlign: TextAlign.center,
                  style: text.titleLarge
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 88),
                    textStyle: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => _done(context, ref),
                  child: Text(l10n.iTookIt),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    textStyle: const TextStyle(fontSize: 20),
                    foregroundColor: scheme.onPrimaryContainer,
                  ),
                  onPressed: () => _snooze(context, ref),
                  child: Text(l10n.snooze10),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _close(context, ref),
                  child: Text(l10n.close,
                      style: TextStyle(color: scheme.onPrimaryContainer)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}