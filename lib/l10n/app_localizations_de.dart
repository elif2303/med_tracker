// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Med Tracker';

  @override
  String get nextMedicine => 'Nächstes Medikament';

  @override
  String get iTookIt => 'Eingenommen';

  @override
  String get allDoneToday => 'Für heute alles erledigt!';

  @override
  String get noMedicinesYet => 'Noch keine Medikamente';

  @override
  String get noMedicinesHint =>
      'Noch keine Medikamente.\nTippe auf +, um eines hinzuzufügen.';

  @override
  String get addMedicine => 'Medikament hinzufügen';

  @override
  String get medicineName => 'Name des Medikaments';

  @override
  String get doseHint => 'Dosis (z. B. 1 Tablette, 5 ml)';

  @override
  String get timesEveryDay => 'Uhrzeiten (täglich)';

  @override
  String get addTime => 'Uhrzeit hinzufügen';

  @override
  String get addAtLeastOneTime => 'Füge mindestens eine Uhrzeit hinzu';

  @override
  String get enterName => 'Bitte einen Namen eingeben';

  @override
  String get save => 'Speichern';

  @override
  String get deleteMedicine => 'Medikament löschen';

  @override
  String deleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteBody => 'Alle Uhrzeiten und der Verlauf werden entfernt.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get standardView => 'Standardansicht';

  @override
  String get switchToLarge => 'Zu Groß & Einfach wechseln';

  @override
  String get testNotification => 'Testbenachrichtigung (10 s)';

  @override
  String get language => 'Sprache';

  @override
  String get systemDefault => 'Systemsprache';

  @override
  String reminderTitle(String name) {
    return 'Zeit für $name';
  }

  @override
  String get testTitle => 'Test-Erinnerung';

  @override
  String get testBody => 'Benachrichtigungen funktionieren!';

  @override
  String get channelName => 'Medikamenten-Erinnerungen';

  @override
  String get channelDescription =>
      'Tägliche Erinnerungen zur Medikamenteneinnahme';

  @override
  String get loudAlarm => 'Lauter Alarm';

  @override
  String get loudAlarmHint =>
      'Klingelt laut und wiederholt sich, bis du reagierst';

  @override
  String get snooze10 => '10 Min. später';

  @override
  String get alarmChannelName => 'Medikamenten-Alarme';

  @override
  String get alarmChannelDescription =>
      'Laute Alarme für Medikamente im Alarmmodus';

  @override
  String get today => 'Heute';

  @override
  String dosesProgress(int taken, int total) {
    return '$taken von $total eingenommen';
  }

  @override
  String nextUp(String name, String time) {
    return 'Als Nächstes: $name um $time';
  }

  @override
  String get periodMorning => 'Morgens';

  @override
  String get periodAfternoon => 'Nachmittags';

  @override
  String get periodEvening => 'Abends';

  @override
  String get periodNight => 'Nachts';

  @override
  String get overdue => 'Überfällig';

  @override
  String get pickDate => 'Datum wählen';

  @override
  String dosesPlanned(int total) {
    return '$total Einnahmen geplant';
  }

  @override
  String get noDosesThisDay => 'Keine Einnahmen an diesem Tag';

  @override
  String get everyDay => 'Jeden Tag';

  @override
  String get whichDays => 'An welchen Tagen?';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get noEndDate => 'Kein Enddatum (fortlaufend)';

  @override
  String get pickAtLeastOneDay => 'Wähle mindestens einen Tag';

  @override
  String get me => 'Ich';

  @override
  String get addPerson => 'Person hinzufügen';

  @override
  String get editPerson => 'Person bearbeiten';

  @override
  String get personName => 'Name (z. B. Mama)';

  @override
  String get color => 'Farbe';

  @override
  String get deletePersonBody =>
      'Alle Medikamente und der Verlauf dieser Person werden entfernt.';

  @override
  String get forWhom => 'Für';

  @override
  String reminderTitleFor(String profile, String name) {
    return '$profile: Zeit für $name';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get showNameInNotification =>
      'Namen der Person in Benachrichtigungen anzeigen';

  @override
  String get showNameInNotificationHint =>
      'Jeder, der den Sperrbildschirm sieht, kann es lesen';

  @override
  String get testSection => 'Test';

  @override
  String get medicalDisclaimer =>
      'Med Tracker ist ein Erinnerungswerkzeug und bietet keine medizinische Beratung. Befolge immer die Anweisungen deines Arztes.';

  @override
  String get editMedicine => 'Medikament bearbeiten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get obWelcomeTitle => 'Willkommen bei Med Tracker';

  @override
  String get obWelcomeBody =>
      'Verpasse keine Einnahme mehr. Einfache Erinnerungen für dich und die Menschen, die du betreust.';

  @override
  String get obDisclaimerTitle => 'Bevor es losgeht';

  @override
  String get obDataLocal =>
      'Deine Medikamente und dein Verlauf werden nur auf diesem Handy gespeichert. Wenn du die App löschst oder das Handy wechselst, gehen sie verloren.';

  @override
  String get obAgree => 'Ich habe verstanden und stimme zu';

  @override
  String get obPermTitle => 'Erinnerungen erlauben';

  @override
  String get obPermBody =>
      'Damit Med Tracker dich pünktlich erinnern kann, braucht die App deine Erlaubnis:';

  @override
  String get obPermNotif =>
      'Benachrichtigungen, um deine Erinnerungen anzuzeigen';

  @override
  String get obPermExact =>
      'Exakte Alarme, damit Erinnerungen pünktlich und nicht Minuten zu spät kommen';

  @override
  String get obAllow => 'Erlauben';

  @override
  String get obNotNow => 'Jetzt nicht';

  @override
  String get obBatteryTitle => 'Erinnerungen zuverlässig halten';

  @override
  String get obBatteryBody =>
      'Einige Handys (Samsung, Xiaomi, Huawei u. a.) pausieren Apps, um Akku zu sparen, wodurch sich Erinnerungen verzögern können. Öffne die Einstellungen, gehe zu Akku und wähle „Uneingeschränkt“.';

  @override
  String get obOpenSettings => 'Einstellungen öffnen';

  @override
  String get obGetStarted => 'Los geht\'s';

  @override
  String get close => 'Schließen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';
}
