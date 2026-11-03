import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Med Tracker'**
  String get appTitle;

  /// No description provided for @nextMedicine.
  ///
  /// In en, this message translates to:
  /// **'Next medicine'**
  String get nextMedicine;

  /// No description provided for @iTookIt.
  ///
  /// In en, this message translates to:
  /// **'I took it'**
  String get iTookIt;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All done for today!'**
  String get allDoneToday;

  /// No description provided for @noMedicinesYet.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get noMedicinesYet;

  /// No description provided for @noMedicinesHint.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet.\nTap + to add one.'**
  String get noMedicinesHint;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineName;

  /// No description provided for @doseHint.
  ///
  /// In en, this message translates to:
  /// **'Dose (e.g. 1 tablet, 5 ml)'**
  String get doseHint;

  /// No description provided for @timesEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Times every day'**
  String get timesEveryDay;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @addAtLeastOneTime.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time'**
  String get addAtLeastOneTime;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete medicine'**
  String get deleteMedicine;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteTitle(String name);

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'All its times and history will be removed.'**
  String get deleteBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @standardView.
  ///
  /// In en, this message translates to:
  /// **'Standard view'**
  String get standardView;

  /// No description provided for @switchToLarge.
  ///
  /// In en, this message translates to:
  /// **'Switch to Large & Simple'**
  String get switchToLarge;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test notification (10 s)'**
  String get testNotification;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {name}'**
  String reminderTitle(String name);

  /// No description provided for @testTitle.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testTitle;

  /// No description provided for @testBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are working!'**
  String get testBody;

  /// No description provided for @channelName.
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get channelName;

  /// No description provided for @channelDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders to take your medicine'**
  String get channelDescription;

  /// No description provided for @loudAlarm.
  ///
  /// In en, this message translates to:
  /// **'Loud alarm'**
  String get loudAlarm;

  /// No description provided for @loudAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'Rings loudly and repeats until you respond'**
  String get loudAlarmHint;

  /// No description provided for @snooze10.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get snooze10;

  /// No description provided for @alarmChannelName.
  ///
  /// In en, this message translates to:
  /// **'Medication alarms'**
  String get alarmChannelName;

  /// No description provided for @alarmChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Loud alarms for medicines set as alarm'**
  String get alarmChannelDescription;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @dosesProgress.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} taken'**
  String dosesProgress(int taken, int total);

  /// No description provided for @nextUp.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} at {time}'**
  String nextUp(String name, String time);

  /// No description provided for @periodMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get periodMorning;

  /// No description provided for @periodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get periodAfternoon;

  /// No description provided for @periodEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get periodEvening;

  /// No description provided for @periodNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get periodNight;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @dosesPlanned.
  ///
  /// In en, this message translates to:
  /// **'{total} doses planned'**
  String dosesPlanned(int total);

  /// No description provided for @noDosesThisDay.
  ///
  /// In en, this message translates to:
  /// **'No doses on this day'**
  String get noDosesThisDay;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @whichDays.
  ///
  /// In en, this message translates to:
  /// **'Which days?'**
  String get whichDays;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date (ongoing)'**
  String get noEndDate;

  /// No description provided for @pickAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get pickAtLeastOneDay;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Mom)'**
  String get personName;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'All medicines and history of this person will be removed.'**
  String get deletePersonBody;

  /// No description provided for @forWhom.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forWhom;

  /// No description provided for @reminderTitleFor.
  ///
  /// In en, this message translates to:
  /// **'{profile}: time for {name}'**
  String reminderTitleFor(String profile, String name);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @showNameInNotification.
  ///
  /// In en, this message translates to:
  /// **'Show person\'s name in notifications'**
  String get showNameInNotification;

  /// No description provided for @showNameInNotificationHint.
  ///
  /// In en, this message translates to:
  /// **'Anyone who sees your lock screen can read it'**
  String get showNameInNotificationHint;

  /// No description provided for @testSection.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testSection;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Med Tracker is a reminder tool and does not provide medical advice. Always follow your doctor\'s instructions.'**
  String get medicalDisclaimer;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Med Tracker'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Never miss a dose. Simple reminders for you and the people you care for.'**
  String get obWelcomeBody;

  /// No description provided for @obDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get obDisclaimerTitle;

  /// No description provided for @obDataLocal.
  ///
  /// In en, this message translates to:
  /// **'Your medicines and history are stored only on this phone. If you delete the app or change phones, they are lost.'**
  String get obDataLocal;

  /// No description provided for @obAgree.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get obAgree;

  /// No description provided for @obPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow reminders'**
  String get obPermTitle;

  /// No description provided for @obPermBody.
  ///
  /// In en, this message translates to:
  /// **'To remind you on time, Med Tracker needs your permission:'**
  String get obPermBody;

  /// No description provided for @obPermNotif.
  ///
  /// In en, this message translates to:
  /// **'Notifications, to show your reminders'**
  String get obPermNotif;

  /// No description provided for @obPermExact.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms, so reminders arrive on time and not minutes late'**
  String get obPermExact;

  /// No description provided for @obAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get obAllow;

  /// No description provided for @obNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get obNotNow;

  /// No description provided for @obBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep reminders reliable'**
  String get obBatteryTitle;

  /// No description provided for @obBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones (Samsung, Xiaomi, Huawei and others) pause apps to save battery, which can delay reminders. Open the settings, go to Battery and choose \"Unrestricted\".'**
  String get obBatteryBody;

  /// No description provided for @obOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get obOpenSettings;

  /// No description provided for @obGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get obGetStarted;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
