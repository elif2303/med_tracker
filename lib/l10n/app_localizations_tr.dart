// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Med Tracker';

  @override
  String get nextMedicine => 'Sıradaki ilaç';

  @override
  String get iTookIt => 'Aldım';

  @override
  String get allDoneToday => 'Bugünlük hepsi tamam!';

  @override
  String get noMedicinesYet => 'Henüz ilaç yok';

  @override
  String get noMedicinesHint =>
      'Henüz ilaç yok.\nEklemek için + düğmesine dokun.';

  @override
  String get addMedicine => 'İlaç ekle';

  @override
  String get medicineName => 'İlaç adı';

  @override
  String get doseHint => 'Doz (örn. 1 tablet, 5 ml)';

  @override
  String get timesEveryDay => 'Her gün saatleri';

  @override
  String get addTime => 'Saat ekle';

  @override
  String get addAtLeastOneTime => 'En az bir saat ekle';

  @override
  String get enterName => 'Bir ad gir';

  @override
  String get save => 'Kaydet';

  @override
  String get deleteMedicine => 'İlacı sil';

  @override
  String deleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get deleteBody => 'Tüm saatleri ve geçmişi silinecek.';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get standardView => 'Standart görünüm';

  @override
  String get switchToLarge => 'Büyük ve sade görünüme geç';

  @override
  String get testNotification => 'Test bildirimi (10 sn)';

  @override
  String get language => 'Dil';

  @override
  String get systemDefault => 'Sistem dili';

  @override
  String reminderTitle(String name) {
    return '$name zamanı';
  }

  @override
  String get testTitle => 'Test hatırlatıcı';

  @override
  String get testBody => 'Bildirimler çalışıyor!';

  @override
  String get channelName => 'İlaç hatırlatıcıları';

  @override
  String get channelDescription => 'İlacını almak için günlük hatırlatmalar';

  @override
  String get loudAlarm => 'Sesli alarm';

  @override
  String get loudAlarmHint =>
      'Sen cevap verene kadar yüksek sesle çalar ve tekrarlar';

  @override
  String get snooze10 => '10 dk ertele';

  @override
  String get alarmChannelName => 'İlaç alarmları';

  @override
  String get alarmChannelDescription =>
      'Alarm olarak ayarlanan ilaçlar için yüksek sesli alarmlar';

  @override
  String get today => 'Bugün';

  @override
  String dosesProgress(int taken, int total) {
    return '$taken / $total alındı';
  }

  @override
  String nextUp(String name, String time) {
    return 'Sıradaki: $name • $time';
  }

  @override
  String get periodMorning => 'Sabah';

  @override
  String get periodAfternoon => 'Öğleden sonra';

  @override
  String get periodEvening => 'Akşam';

  @override
  String get periodNight => 'Gece';

  @override
  String get overdue => 'Gecikti';

  @override
  String get pickDate => 'Tarih seç';

  @override
  String dosesPlanned(int total) {
    return '$total doz planlandı';
  }

  @override
  String get noDosesThisDay => 'Bu gün için doz yok';

  @override
  String get everyDay => 'Her gün';

  @override
  String get whichDays => 'Hangi günler?';

  @override
  String get startDate => 'Başlangıç tarihi';

  @override
  String get endDate => 'Bitiş tarihi';

  @override
  String get noEndDate => 'Bitiş yok (devam ediyor)';

  @override
  String get pickAtLeastOneDay => 'En az bir gün seç';

  @override
  String get me => 'Ben';

  @override
  String get addPerson => 'Kişi ekle';

  @override
  String get editPerson => 'Kişiyi düzenle';

  @override
  String get personName => 'Ad (örn. Annem)';

  @override
  String get color => 'Renk';

  @override
  String get deletePersonBody =>
      'Bu kişinin tüm ilaçları ve geçmişi silinecek.';

  @override
  String get forWhom => 'Kimin için';

  @override
  String reminderTitleFor(String profile, String name) {
    return '$profile: $name zamanı';
  }
}
