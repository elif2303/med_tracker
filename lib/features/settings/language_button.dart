import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/locale_provider.dart';
import '../../l10n/app_localizations.dart';

const appLanguages = {
  'en': 'English',
  'tr': 'Türkçe',
  'de': 'Deutsch',
  'ar': 'العربية',
};

Future<void> showLanguageDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final notifier = ref.read(localeProvider.notifier);
      void choose(Locale? l) {
        notifier.set(l);
        Navigator.pop(ctx);
      }

      return SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(
            onPressed: () => choose(null),
            child: Text(l10n.systemDefault),
          ),
          for (final e in appLanguages.entries)
            SimpleDialogOption(
              onPressed: () => choose(Locale(e.key)),
              child: Text(e.value),
            ),
        ],
      );
    },
  );
}

class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context).language,
      icon: const Icon(Icons.language),
      onPressed: () => showLanguageDialog(context, ref),
    );
  }
}