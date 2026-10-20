import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/locale_provider.dart';
import 'core/theme.dart';
import 'core/ui_mode.dart';
import 'data/providers.dart';
import 'features/home_large/large_home_screen.dart';
import 'features/home_standard/standard_home_screen.dart';
import 'l10n/app_localizations.dart';
import 'notifications/notification_service.dart';
import 'core/time_utils.dart';

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
    final mode = ref.watch(uiModeProvider);
    final locale = ref.watch(localeProvider);
    ref.watch(notificationSyncProvider);

    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(mode, Brightness.light),
      darkTheme: buildTheme(mode, Brightness.dark),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final systemScale = mq.textScaler.scale(14) / 14;
        final scale = systemScale * (mode == UiMode.large ? 1.5 : 1.0);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      home: mode == UiMode.large
          ? const LargeHomeScreen()
          : const StandardHomeScreen(),
    );
  }
}