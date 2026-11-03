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

  @override
  String get me => 'Me';

  @override
  String get addPerson => 'Add person';

  @override
  String get editPerson => 'Edit person';

  @override
  String get personName => 'Name (e.g. Mom)';

  @override
  String get color => 'Color';

  @override
  String get deletePersonBody =>
      'All medicines and history of this person will be removed.';

  @override
  String get forWhom => 'For';

  @override
  String reminderTitleFor(String profile, String name) {
    return '$profile: time for $name';
  }

  @override
  String get settings => 'Settings';

  @override
  String get showNameInNotification => 'Show person\'s name in notifications';

  @override
  String get showNameInNotificationHint =>
      'Anyone who sees your lock screen can read it';

  @override
  String get testSection => 'Test';

  @override
  String get medicalDisclaimer =>
      'Med Tracker is a reminder tool and does not provide medical advice. Always follow your doctor\'s instructions.';

  @override
  String get editMedicine => 'Edit medicine';

  @override
  String get edit => 'Edit';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get obWelcomeTitle => 'Welcome to Med Tracker';

  @override
  String get obWelcomeBody =>
      'Never miss a dose. Simple reminders for you and the people you care for.';

  @override
  String get obDisclaimerTitle => 'Before you start';

  @override
  String get obDataLocal =>
      'Your medicines and history are stored only on this phone. If you delete the app or change phones, they are lost.';

  @override
  String get obAgree => 'I understand and agree';

  @override
  String get obPermTitle => 'Allow reminders';

  @override
  String get obPermBody =>
      'To remind you on time, Med Tracker needs your permission:';

  @override
  String get obPermNotif => 'Notifications, to show your reminders';

  @override
  String get obPermExact =>
      'Exact alarms, so reminders arrive on time and not minutes late';

  @override
  String get obAllow => 'Allow';

  @override
  String get obNotNow => 'Not now';

  @override
  String get obBatteryTitle => 'Keep reminders reliable';

  @override
  String get obBatteryBody =>
      'Some phones (Samsung, Xiaomi, Huawei and others) pause apps to save battery, which can delay reminders. Open the settings, go to Battery and choose \"Unrestricted\".';

  @override
  String get obOpenSettings => 'Open settings';

  @override
  String get obGetStarted => 'Get started';

  @override
  String get close => 'Close';

  @override
  String get privacyPolicy => 'Privacy policy';
}
