import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/locale_provider.dart';
import '../../core/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../settings/language_button.dart';

/// android/app/build.gradle.kts içindeki applicationId ile aynı olmalı
const _androidPackage = 'com.maez.med_tracker';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;
  final _controller = PageController();
  int _page = 0;
  bool _agreed = false;
  bool _busy = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _allowPermissions() async {
    setState(() => _busy = true);
    await NotificationService.instance.requestPermissions();
    if (!mounted) return;
    setState(() => _busy = false);
    _goTo(3);
  }

  Future<void> _openBatterySettings() async {
    if (!_isAndroid) return;
    await const AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:$_androidPackage',
    ).launch();
  }

  Widget _bottomButtons(AppLocalizations l10n) {
    switch (_page) {
      case 0:
        return FilledButton(
          onPressed: () => _goTo(1),
          child: Text(l10n.next),
        );
      case 1:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goTo(0),
                child: Text(l10n.back),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _agreed ? () => _goTo(2) : null,
                child: Text(l10n.next),
              ),
            ),
          ],
        );
      case 2:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _goTo(3),
                child: Text(l10n.obNotNow),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : _allowPermissions,
                child: Text(l10n.obAllow),
              ),
            ),
          ],
        );
      default:
        return FilledButton(
          onPressed: () =>
              ref.read(onboardingDoneProvider.notifier).complete(),
          child: Text(l10n.obGetStarted),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  // 1) Karşılama + dil
                  _OnbPage(
                    icon: Icons.medication_outlined,
                    title: l10n.obWelcomeTitle,
                    children: [
                      Text(l10n.obWelcomeBody,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge),
                      const SizedBox(height: 28),
                      Text(l10n.language,
                          style: text.titleSmall
                              ?.copyWith(color: scheme.primary)),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.systemDefault),
                            selected: locale == null,
                            onSelected: (_) => ref
                                .read(localeProvider.notifier)
                                .set(null),
                          ),
                          for (final e in appLanguages.entries)
                            ChoiceChip(
                              label: Text(e.value),
                              selected: locale?.languageCode == e.key,
                              onSelected: (_) => ref
                                  .read(localeProvider.notifier)
                                  .set(Locale(e.key)),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // 2) Uyarı ve onay
                  _OnbPage(
                    icon: Icons.health_and_safety_outlined,
                    title: l10n.obDisclaimerTitle,
                    children: [
                      Text(l10n.medicalDisclaimer,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge),
                      const SizedBox(height: 16),
                      Text(l10n.obDataLocal,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _agreed,
                        onChanged: (v) =>
                            setState(() => _agreed = v ?? false),
                        title: Text(l10n.obAgree),
                      ),
                    ],
                  ),

                  // 3) İzinler
                  _OnbPage(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.obPermTitle,
                    children: [
                      Text(l10n.obPermBody,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge),
                      const SizedBox(height: 20),
                      _Bullet(
                          icon: Icons.notifications_outlined,
                          text: l10n.obPermNotif),
                      _Bullet(
                          icon: Icons.alarm_on_outlined,
                          text: l10n.obPermExact),
                    ],
                  ),

                  // 4) Pil optimizasyonu
                  _OnbPage(
                    icon: Icons.battery_charging_full_outlined,
                    title: l10n.obBatteryTitle,
                    children: [
                      Text(l10n.obBatteryBody,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge),
                      if (_isAndroid) ...[
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _openBatterySettings,
                          icon: const Icon(Icons.settings_outlined),
                          label: Text(l10n.obOpenSettings),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pageCount; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          i == _page ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: _bottomButtons(l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbPage extends StatelessWidget {
  const _OnbPage({
    required this.icon,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: scheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}