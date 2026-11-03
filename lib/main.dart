import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/locale_provider.dart';
import 'core/settings_provider.dart';
import 'core/theme.dart';
import 'core/time_utils.dart';
import 'data/providers.dart';
import 'features/alarm/alarm_request.dart';
import 'features/alarm/alarm_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';
import 'notifications/notification_service.dart';

final _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  final container = ProviderContainer(overrides: [
    initialProfileIdProvider.overrideWithValue(prefs.getInt('selected_profile')),
    initialOnboardingDoneProvider.overrideWithValue(onboardingDone),
  ]);

  final service = NotificationService.instance;
  service.onTaken = (reminderId) => container
      .read(databaseProvider)
      .markTaken(reminderId, dayKeyOf(DateTime.now()));
  service.onOpened =
      (req) => container.read(alarmRequestProvider.notifier).set(req);

  await service.init();
  if (onboardingDone) {
    await service.requestNotificationPermissionOnly();
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MedTrackerApp(),
  ));
}

class MedTrackerApp extends ConsumerStatefulWidget {
  const MedTrackerApp({super.key});

  @override
  ConsumerState<MedTrackerApp> createState() => _MedTrackerAppState();
}

class _MedTrackerAppState extends ConsumerState<MedTrackerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual<AlarmRequest?>(
      alarmRequestProvider,
      (_, next) {
        if (next != null) _showAlarm(next);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Arka plandaki "Aldım" kayıtları ana ekrana yansısın
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(selectedDosesProvider);
    }
  }

  void _showAlarm(AlarmRequest req) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AlarmScreen(request: req)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final seed = ref.watch(activeColorProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);
    ref.watch(notificationSyncProvider);

    return MaterialApp(
      navigatorKey: _navKey,
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, seed),
      darkTheme: buildTheme(Brightness.dark, seed),
      themeAnimationDuration: const Duration(milliseconds: 400),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: onboardingDone ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}