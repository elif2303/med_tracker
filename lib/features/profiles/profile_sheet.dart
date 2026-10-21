import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/profile_colors.dart';
import '../../core/profile_utils.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// profile == null ise yeni kişi ekler, doluysa düzenler
Future<void> showProfileSheet(BuildContext context, {Profile? profile}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ProfileSheet(profile: profile),
  );
}

class _ProfileSheet extends ConsumerStatefulWidget {
  const _ProfileSheet({this.profile});
  final Profile? profile;

  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  late final TextEditingController _name;
  late int _color;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p?.name ?? '');
    final count = ref.read(profilesProvider).value?.length ?? 0;
    _color = p?.colorValue ?? profileColors[count % profileColors.length];
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final p = widget.profile;
    final isSelf = p?.isSelf ?? false;
    if (name.isEmpty && !isSelf) {
      setState(() => _nameError = true);
      return;
    }
    final db = ref.read(databaseProvider);
    if (p == null) {
      final id = await db.addProfile(name, _color);
      ref.read(selectedProfileProvider.notifier).set(id);
    } else {
      await db.updateProfile(p.id, name, _color);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final p = widget.profile!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTitle(profileLabel(l10n, p.name))),
        content: Text(l10n.deletePersonBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(databaseProvider).deleteProfile(p.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = widget.profile;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p == null ? l10n.addPerson : l10n.editPerson,
                style: text.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: p == null,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.personName,
                hintText: (p?.isSelf ?? false) ? l10n.me : null,
                errorText: _nameError ? l10n.enterName : null,
              ),
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
            ),
            const SizedBox(height: 20),
            Text(l10n.color, style: text.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in profileColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: scheme.onSurface, width: 3)
                            : null,
                      ),
                      child: _color == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
            if (p != null && !p.isSelf) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                child: Text(l10n.delete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}