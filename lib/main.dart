import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/locale_provider.dart';
import 'core/theme.dart';
import 'core/time_utils.dart';
import 'data/providers.dart';
import 'features/home/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  NotificationService.instance.onTaken = (reminderId) => container
      .read(databaseProvider)
      .markTaken(reminderId, dayKeyOf(DateTime.now()));

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MedTrackerApp(),
  ));
}

class MedTrackerApp extends ConsumerWidget {
  const MedTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    ref.watch(notificationSyncProvider);

    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}