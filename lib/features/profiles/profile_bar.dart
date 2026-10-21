import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/profile_utils.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'profile_sheet.dart';

/// Üstteki kişi seçici. Seçili kişiye tekrar dokunmak ya da uzun basmak düzenler.
class ProfileBar extends ConsumerWidget {
  const ProfileBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final activeId = ref.watch(activeProfileIdProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final p in profiles)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: GestureDetector(
                onLongPress: () => showProfileSheet(context, profile: p),
                child: ChoiceChip(
                  avatar: _Initial(
                    label: profileLabel(l10n, p.name),
                    color: Color(p.colorValue),
                  ),
                  label: Text(profileLabel(l10n, p.name)),
                  selected: p.id == activeId,
                  onSelected: (_) {
                    if (p.id == activeId) {
                      showProfileSheet(context, profile: p);
                    } else {
                      ref.read(selectedProfileProvider.notifier).set(p.id);
                    }
                  },
                ),
              ),
            ),
          ActionChip(
            avatar: const Icon(Icons.person_add_alt_1, size: 18),
            label: Text(l10n.addPerson),
            onPressed: () => showProfileSheet(context),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final letter = label.isEmpty
        ? '?'
        : String.fromCharCode(label.runes.first).toUpperCase();
    return CircleAvatar(
      backgroundColor: color,
      radius: 12,
      child: Text(
        letter,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}