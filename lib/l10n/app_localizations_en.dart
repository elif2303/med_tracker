// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Med Tracker';

  @override
  String get nextMedicine => 'Next medicine';

  @override
  String get iTookIt => 'I took it';

  @override
  String get allDoneToday => 'All done for today!';

  @override
  String get noMedicinesYet => 'No medicines yet';

  @override
  String get noMedicinesHint => 'No medicines yet.\nTap + to add one.';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get medicineName => 'Medicine name';

  @override
  String get doseHint => 'Dose (e.g. 1 tablet, 5 ml)';

  @override
  String get timesEveryDay => 'Times every day';

  @override
  String get addTime => 'Add time';

  @override
  String get addAtLeastOneTime => 'Add at least one time';

  @override
  String get enterName => 'Enter a name';

  @override
  String get save => 'Save';

  @override
  String get deleteMedicine => 'Delete medicine';

  @override
  String deleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteBody => 'All its times and history will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get standardView => 'Standard view';

  @override
  String get switchToLarge => 'Switch to Large & Simple';

  @override
  String get testNotification => 'Test notification (10 s)';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String reminderTitle(String name) {
    return 'Time for $name';
  }

  @override
  String get testTitle => 'Test reminder';

  @override
  String get testBody => 'Notifications are working!';

  @override
  String get channelName => 'Medication reminders';

  @override
  String get channelDescription => 'Daily reminders to take your medicine';

  @override
  String get loudAlarm => 'Loud alarm';

  @override
  String get loudAlarmHint => 'Rings loudly and repeats until you respond';

  @override
  String get snooze10 => 'Snooze 10 min';

  @override
  String get alarmChannelName => 'Medication alarms';

  @override
  String get alarmChannelDescription =>
      'Loud alarms for medicines set as alarm';

  @override
  String get today => 'Today';

  @override
  String dosesProgress(int taken, int total) {
    return '$taken of $total taken';
  }

  @override
  String nextUp(String name, String time) {
    return 'Next: $name at $time';
  }

  @override
  String get periodMorning => 'Morning';

  @override
  String get periodAfternoon => 'Afternoon';

  @override
  String get periodEvening => 'Evening';

  @override
  String get periodNight => 'Night';

  @override
  String get overdue => 'Overdue';

  @override
  String get pickDate => 'Pick a date';

  @override
  String dosesPlanned(int total) {
    return '$total doses planned';
  }

  @override
  String get noDosesThisDay => 'No doses on this day';

  @override
  String get everyDay => 'Every day';

  @override
  String get whichDays => 'Which days?';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get noEndDate => 'No end date (ongoing)';

  @override
  String get pickAtLeastOneDay => 'Select at least one day';
}
