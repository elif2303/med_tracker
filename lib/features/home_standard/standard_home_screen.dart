import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/locale_provider.dart';
import '../../core/time_utils.dart';
import '../../core/ui_mode.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../medications/add_medication_screen.dart';
import '../settings/language_button.dart';

enum _Period { morning, afternoon, evening, night }

_Period _periodOf(int m) {
  if (m >= 300 && m < 720) return _Period.morning;
  if (m >= 720 && m < 1020) return _Period.afternoon;
  if (m >= 1020 && m < 1260) return _Period.evening;
  return _Period.night;
}

String _periodLabel(AppLocalizations l10n, _Period p) => switch (p) {
      _Period.morning => l10n.periodMorning,
      _Period.afternoon => l10n.periodAfternoon,
      _Period.evening => l10n.periodEvening,
      _Period.night => l10n.periodNight,
    };

class StandardHomeScreen extends ConsumerWidget {
  const StandardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.watch(todayKeyProvider); // gece yarısı yeniden çizim için
    final selected = ref.watch(selectedDateProvider);
    final dosesAsync = ref.watch(selectedDosesProvider);
    final hasMeds = ref.watch(schedulesProvider).value?.isNotEmpty ?? false;
    final db = ref.read(databaseProvider);

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final cmp = selected.compareTo(todayDate);
    final isToday = cmp == 0;
    final isFuture = cmp > 0;
    final dayKey = dayKeyOf(selected);

    void openAdd() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
        );

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selected,
        firstDate:
            DateTime(todayDate.year, todayDate.month, todayDate.day - 30),
        lastDate: DateTime(todayDate.year, todayDate.month, todayDate.day + 30),
      );
      if (picked != null) ref.read(selectedDateProvider.notifier).set(picked);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () =>
                  ref.read(selectedDateProvider.notifier).set(todayDate),
              child: Text(l10n.today),
            ),
          IconButton(
            tooltip: l10n.pickDate,
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
          ),
          const LanguageButton(),
          IconButton(
            tooltip: l10n.switchToLarge,
            icon: const Icon(Icons.accessibility_new),
            onPressed: () =>
                ref.read(uiModeProvider.notifier).set(UiMode.large),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => NotificationService.instance
                .scheduleTest(ref.read(localeProvider), alarm: v == 'alarm'),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'notification', child: Text(l10n.testNotification)),
              PopupMenuItem(value: 'alarm', child: Text(l10n.loudAlarm)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (hasMeds)
            _DateStrip(
              selected: selected,
              onSelect: (d) => ref.read(selectedDateProvider.notifier).set(d),
            ),
          Expanded(
            child: dosesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (doses) {
                if (!hasMeds) return _EmptyState(onAdd: openAdd);

                if (doses.isEmpty) {
                  return Center(child: Text(l10n.noDosesThisDay));
                }

                final taken = doses.where((d) => d.taken).length;
                final next = doses.where((d) => !d.taken).firstOrNull;
                final nowMinute = now.hour * 60 + now.minute;

                final groups = <_Period, List<DoseItem>>{};
                for (final d in doses) {
                  groups.putIfAbsent(_periodOf(d.minuteOfDay), () => []).add(d);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  children: [
                    _SummaryCard(
                      date: selected,
                      isToday: isToday,
                      isFuture: isFuture,
                      taken: taken,
                      total: doses.length,
                      next: isToday ? next : null,
                    ),
                    for (final p in _Period.values)
                      if (groups[p] case final list?) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                          child: Text(
                            _periodLabel(l10n, p),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        for (final d in list)
                          _DoseCard(
                            dose: d,
                            future: isFuture,
                            overdue: isToday &&
                                !d.taken &&
                                d.minuteOfDay < nowMinute,
                            onToggle: isFuture
                                ? null
                                : () => d.taken
                                    ? db.unmarkTaken(d.reminderId, dayKey)
                                    : db.markTaken(d.reminderId, dayKey),
                            onDelete: () => _confirmDelete(context, db, d),
                          ),
                      ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAdd,
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedicine),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppDatabase db, DoseItem d) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTitle(d.name)),
        content: Text(l10n.deleteBody),
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
    if (ok == true) await db.deleteMedication(d.medicationId);
  }
}

/// Yatay kaydırılabilir gün şeridi: bugünden 30 gün önce / 30 gün sonra
class _DateStrip extends StatefulWidget {
  const _DateStrip({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<_DateStrip> {
  static const _range = 30;
  static const _itemWidth = 64.0;

  late final DateTime _today;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _today = DateTime(n.year, n.month, n.day);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelected(animate: false));
  }

  @override
  void didUpdateWidget(covariant _DateStrip old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _scrollToSelected(animate: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _indexOf(DateTime d) {
    final a = DateTime.utc(d.year, d.month, d.day);
    final b = DateTime.utc(_today.year, _today.month, _today.day);
    return a.difference(b).inDays + _range;
  }

  void _scrollToSelected({required bool animate}) {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    final target = (_indexOf(widget.selected) * _itemWidth -
            (pos.viewportDimension / 2 - _itemWidth / 2))
        .clamp(pos.minScrollExtent, pos.maxScrollExtent);
    if (animate) {
      _controller.animateTo(target,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _controller.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();

    return SizedBox(
      height: 84,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemExtent: _itemWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _range * 2 + 1,
        itemBuilder: (context, i) {
          final d = DateTime(
              _today.year, _today.month, _today.day + i - _range);
          final isSel = d == widget.selected;
          final isToday = d == _today;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSel ? scheme.primary : scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: isToday && !isSel
                    ? BorderSide(color: scheme.primary, width: 1.5)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => widget.onSelect(d),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.E(locale).format(d),
                      style: text.labelMedium?.copyWith(
                        color: isSel
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.day}',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSel ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.date,
    required this.isToday,
    required this.isFuture,
    required this.taken,
    required this.total,
    required this.next,
  });
  final DateTime date;
  final bool isToday;
  final bool isFuture;
  final int taken;
  final int total;
  final DoseItem? next;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final progress = total == 0 ? 0.0 : taken / total;
    final onC = scheme.onPrimaryContainer;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMd(locale).format(date),
                    style: text.labelLarge?.copyWith(color: onC),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isToday ? l10n.today : DateFormat.EEEE(locale).format(date),
                    style: text.headlineMedium
                        ?.copyWith(color: onC, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFuture
                        ? l10n.dosesPlanned(total)
                        : l10n.dosesProgress(taken, total),
                    style: text.titleMedium?.copyWith(color: onC),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 10),
                    Text(
                      next == null
                          ? l10n.allDoneToday
                          : l10n.nextUp(
                              next!.name, formatMinutes(next!.minuteOfDay)),
                      style: text.bodyMedium
                          ?.copyWith(color: onC.withValues(alpha: 0.85)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 84,
              height: 84,
              child: isFuture
                  ? Icon(Icons.event_available, size: 48, color: onC)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          backgroundColor: onC.withValues(alpha: 0.15),
                          color: scheme.primary,
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: text.titleMedium?.copyWith(
                                color: onC, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseCard extends StatelessWidget {
  const _DoseCard({
    required this.dose,
    required this.future,
    required this.overdue,
    required this.onToggle,
    required this.onDelete,
  });
  final DoseItem dose;
  final bool future;
  final bool overdue;
  final VoidCallback? onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final Color badgeBg;
    final Color badgeFg;
    if (dose.taken) {
      badgeBg = scheme.surfaceContainerHighest;
      badgeFg = scheme.onSurfaceVariant;
    } else if (overdue) {
      badgeBg = scheme.errorContainer;
      badgeFg = scheme.onErrorContainer;
    } else {
      badgeBg = scheme.primaryContainer;
      badgeFg = scheme.onPrimaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 4, 14),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    formatMinutes(dose.minuteOfDay),
                    style: text.titleMedium?.copyWith(
                      color: badgeFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dose.name,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              dose.taken ? TextDecoration.lineThrough : null,
                          color: dose.taken
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                      if (dose.dose.isNotEmpty)
                        Text(dose.dose,
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      if (overdue)
                        Text(l10n.overdue,
                            style: text.labelMedium?.copyWith(
                                color: scheme.error,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Icon(
                  future
                      ? Icons.schedule
                      : dose.taken
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                  size: 30,
                  color: dose.taken ? scheme.primary : scheme.outline,
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'delete', child: Text(l10n.deleteMedicine)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication_outlined,
                  size: 64, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(l10n.noMedicinesHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(220, 52)),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addMedicine),
            ),
          ],
        ),
      ),
    );
  }
}