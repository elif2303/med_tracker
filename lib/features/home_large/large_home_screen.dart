import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/time_utils.dart';
import '../../core/ui_mode.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../medications/add_medication_screen.dart';
import '../settings/language_button.dart';

class LargeHomeScreen extends ConsumerWidget {
  const LargeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final dosesAsync = ref.watch(todayDosesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: dosesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (doses) {
              final next = doses.where((d) => !d.taken).firstOrNull;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: LanguageButton(),
                  ),
                  if (doses.isEmpty) ...[
                    const Spacer(),
                    Text(l10n.noMedicinesYet,
                        style: text.headlineMedium,
                        textAlign: TextAlign.center),
                  ] else if (next == null) ...[
                    const Spacer(),
                    const Icon(Icons.check_circle,
                        size: 120, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(l10n.allDoneToday,
                        style: text.headlineMedium,
                        textAlign: TextAlign.center),
                  ] else ...[
                    Text(l10n.nextMedicine, style: text.titleLarge),
                    const SizedBox(height: 16),
                    Text(next.name,
                        style: text.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(doseLine(next.minuteOfDay, next.dose),
                        style: text.headlineSmall),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => ref
                          .read(databaseProvider)
                          .markTaken(next.reminderId, ref.read(todayKeyProvider)),
                      child: Text(l10n.iTookIt),
                    ),
                  ],
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddMedicationScreen()),
                    ),
                    child: Text(l10n.addMedicine),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref
                        .read(uiModeProvider.notifier)
                        .set(UiMode.standard),
                    child: Text(l10n.standardView),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}