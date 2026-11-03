import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/locale_provider.dart';
import '../../core/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import 'language_button.dart';
import 'package:url_launcher/url_launcher.dart';

const privacyPolicyUrl =
    'https://sites.google.com/view/maez-medtracker-privacy';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final showName = ref.watch(showProfileInNotificationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(locale == null
                ? l10n.systemDefault
                : appLanguages[locale.languageCode] ?? locale.languageCode),
            onTap: () => showLanguageDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(
              Uri.parse(privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.badge_outlined),
            title: Text(l10n.showNameInNotification),
            subtitle: Text(l10n.showNameInNotificationHint),
            value: showName,
            onChanged: (v) =>
                ref.read(showProfileInNotificationProvider.notifier).set(v),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              l10n.testSection,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.testNotification),
            onTap: () => NotificationService.instance.scheduleTest(locale),
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: Text(l10n.loudAlarm),
            onTap: () =>
                NotificationService.instance.scheduleTest(locale, alarm: true),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Text(
              l10n.medicalDisclaimer,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}