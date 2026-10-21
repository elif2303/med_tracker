// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Med Tracker';

  @override
  String get nextMedicine => 'الدواء التالي';

  @override
  String get iTookIt => 'تناولته';

  @override
  String get allDoneToday => 'اكتملت جرعات اليوم!';

  @override
  String get noMedicinesYet => 'لا توجد أدوية بعد';

  @override
  String get noMedicinesHint => 'لا توجد أدوية بعد.\nاضغط + لإضافة دواء.';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get medicineName => 'اسم الدواء';

  @override
  String get doseHint => 'الجرعة (مثال: حبة واحدة، 5 مل)';

  @override
  String get timesEveryDay => 'المواعيد اليومية';

  @override
  String get addTime => 'إضافة موعد';

  @override
  String get addAtLeastOneTime => 'أضف موعدًا واحدًا على الأقل';

  @override
  String get enterName => 'أدخل اسمًا';

  @override
  String get save => 'حفظ';

  @override
  String get deleteMedicine => 'حذف الدواء';

  @override
  String deleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deleteBody => 'سيتم حذف جميع مواعيده وسجله.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get standardView => 'العرض العادي';

  @override
  String get switchToLarge => 'التبديل إلى العرض الكبير والبسيط';

  @override
  String get testNotification => 'إشعار تجريبي (10 ثوانٍ)';

  @override
  String get language => 'اللغة';

  @override
  String get systemDefault => 'لغة النظام';

  @override
  String reminderTitle(String name) {
    return 'حان موعد $name';
  }

  @override
  String get testTitle => 'تذكير تجريبي';

  @override
  String get testBody => 'الإشعارات تعمل!';

  @override
  String get channelName => 'تذكيرات الأدوية';

  @override
  String get channelDescription => 'تذكيرات يومية لتناول دوائك';

  @override
  String get loudAlarm => 'منبّه بصوت عالٍ';

  @override
  String get loudAlarmHint => 'يرنّ بصوت عالٍ ويتكرر حتى تستجيب';

  @override
  String get snooze10 => 'تأجيل 10 دقائق';

  @override
  String get alarmChannelName => 'منبهات الأدوية';

  @override
  String get alarmChannelDescription =>
      'منبهات بصوت عالٍ للأدوية المضبوطة كمنبّه';

  @override
  String get today => 'اليوم';

  @override
  String dosesProgress(int taken, int total) {
    return 'تم تناول $taken من $total';
  }

  @override
  String nextUp(String name, String time) {
    return 'التالي: $name الساعة $time';
  }

  @override
  String get periodMorning => 'الصباح';

  @override
  String get periodAfternoon => 'بعد الظهر';

  @override
  String get periodEvening => 'المساء';

  @override
  String get periodNight => 'الليل';

  @override
  String get overdue => 'متأخر';

  @override
  String get pickDate => 'اختر تاريخًا';

  @override
  String dosesPlanned(int total) {
    return '$total جرعات مخطط لها';
  }

  @override
  String get noDosesThisDay => 'لا توجد جرعات في هذا اليوم';

  @override
  String get everyDay => 'كل يوم';

  @override
  String get whichDays => 'في أي أيام؟';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get noEndDate => 'بدون تاريخ انتهاء (مستمر)';

  @override
  String get pickAtLeastOneDay => 'اختر يومًا واحدًا على الأقل';

  @override
  String get me => 'أنا';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get editPerson => 'تعديل الشخص';

  @override
  String get personName => 'الاسم (مثال: أمي)';

  @override
  String get color => 'اللون';

  @override
  String get deletePersonBody => 'سيتم حذف جميع أدوية هذا الشخص وسجله.';

  @override
  String get forWhom => 'لمن';

  @override
  String reminderTitleFor(String profile, String name) {
    return '$profile: حان موعد $name';
  }
}
