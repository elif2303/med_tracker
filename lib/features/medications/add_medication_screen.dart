import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/time_utils.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final List<int> _times = [8 * 60];
  bool _alarm = false;
  int _mask = 127;
  late DateTime _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _start = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    if (_times.contains(minutes)) return;
    setState(() => _times
      ..add(minutes)
      ..sort());
  }

  Future<void> _pickStart() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(today.year, today.month, today.day - 30),
      lastDate: DateTime(today.year + 2, today.month, today.day),
    );
    if (picked == null) return;
    setState(() {
      _start = DateTime(picked.year, picked.month, picked.day);
      if (_end != null && _end!.isBefore(_start)) _end = null;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? _start,
      firstDate: _start,
      lastDate: DateTime(_start.year + 2, _start.month, _start.day),
    );
    if (picked == null) return;
    setState(() => _end = DateTime(picked.year, picked.month, picked.day));
  }

  void _toggleDay(int weekday) {
    setState(() => _mask ^= 1 << (weekday - 1));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.addAtLeastOneTime)));
      return;
    }
    if (_mask == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.pickAtLeastOneDay)));
      return;
    }
    await ref.read(databaseProvider).addMedication(
          name: _name.text.trim(),
          dose: _dose.text.trim(),
          minutes: _times,
          useAlarm: _alarm,
          daysMask: _mask,
          startDay: dayKeyOf(_start),
          endDay: _end == null ? null : dayKeyOf(_end!),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addMedicine)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.medicineName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.enterName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dose,
              decoration: InputDecoration(labelText: l10n.doseHint),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.alarm_on),
              title: Text(l10n.loudAlarm),
              subtitle: Text(l10n.loudAlarmHint),
              value: _alarm,
              onChanged: (v) {
                setState(() => _alarm = v);
                if (v) NotificationService.instance.ensureAlarmPermissions();
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.whichDays, style: titleStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: Text(l10n.everyDay),
                  selected: _mask == 127,
                  onSelected: (_) => setState(() => _mask = 127),
                ),
                for (var wd = 1; wd <= 7; wd++)
                  FilterChip(
                    // 1 Ocak 2024 Pazartesi: wd 1..7 doğru günü verir
                    label: Text(
                        DateFormat.E(locale).format(DateTime(2024, 1, wd))),
                    selected: maskHasDay(_mask, wd),
                    onSelected: (_) => _toggleDay(wd),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(l10n.startDate),
              subtitle: Text(dateFmt.format(_start)),
              onTap: _pickStart,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy),
              title: Text(l10n.endDate),
              subtitle: Text(
                  _end == null ? l10n.noEndDate : dateFmt.format(_end!)),
              trailing: _end == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _end = null),
                    ),
              onTap: _pickEnd,
            ),
            const SizedBox(height: 16),
            Text(l10n.timesEveryDay, style: titleStyle),
            for (final t in _times)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm),
                title: Text(formatMinutes(t)),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _times.remove(t)),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add),
              label: Text(l10n.addTime),
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}