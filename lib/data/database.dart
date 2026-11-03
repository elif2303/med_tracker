import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../core/profile_colors.dart';
import '../core/time_utils.dart';

part 'database.g.dart';

/// Takip edilen kişiler: ben, annem, çocuğum...
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get colorValue => integer()();
  BoolColumn get isSelf => boolean().withDefault(const Constant(false))();
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get dose =>
      text().withLength(max: 80).withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get useAlarm => boolean().withDefault(const Constant(false))();

  /// Hangi günler: bit 0 = Pzt ... bit 6 = Paz. 127 = her gün
  IntColumn get daysMask => integer().withDefault(const Constant(127))();

  /// Başlangıç günü (yyyymmdd). 0 ise eklendiği gün sayılır (eski kayıtlar)
  IntColumn get startDay => integer().withDefault(const Constant(0))();

  /// Bitiş günü (yyyymmdd). null = süresiz
  IntColumn get endDay => integer().nullable()();

  /// Hangi profile ait. 1 = ilk oluşturulan "Ben" profili
  IntColumn get profileId => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Bir ilacın günlük alım saatleri (dakika cinsinden: 08:00 = 480)
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId =>
      integer().references(Medications, #id, onDelete: KeyAction.cascade)();
  IntColumn get minuteOfDay => integer()();
}

/// "Aldım" kayıtları. Aynı saat için aynı gün tek kayıt olabilir.
class IntakeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId =>
      integer().references(Reminders, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayKey => integer()();
  DateTimeColumn get takenAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {reminderId, dayKey},
      ];
}

/// Ekranlarda kullanacağımız birleşik doz bilgisi
class DoseItem {
  final int reminderId;
  final int medicationId;
  final String name;
  final String dose;
  final int minuteOfDay;
  final bool taken;

  const DoseItem({
    required this.reminderId,
    required this.medicationId,
    required this.name,
    required this.dose,
    required this.minuteOfDay,
    required this.taken,
  });
}

/// Bildirim planlamak için kullanılan doz bilgisi
class ScheduleItem {
  final int reminderId;
  final String name;
  final String dose;
  final int minuteOfDay;
  final bool useAlarm;
  final int daysMask;
  final int startDay;
  final int? endDay;
  final int profileId;
  final String profileName;

  const ScheduleItem({
    required this.reminderId,
    required this.name,
    required this.dose,
    required this.minuteOfDay,
    required this.useAlarm,
    required this.daysMask,
    required this.startDay,
    required this.endDay,
    required this.profileId,
    required this.profileName,
  });
}

/// Bu ilaç verilen günde alınmalı mı?
bool isMedicationDueOn(Medication m, int dayKey) {
  final start = m.startDay != 0 ? m.startDay : dayKeyOf(m.createdAt);
  if (dayKey < start) return false;
  if (m.endDay != null && dayKey > m.endDay!) return false;
  return maskHasDay(m.daysMask, dateOfDayKey(dayKey).weekday);
}

@DriftDatabase(tables: [Profiles, Medications, Reminders, IntakeLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'med_tracker',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _insertSelfProfile();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(medications, medications.useAlarm);
          }
          if (from < 3) {
            await m.addColumn(medications, medications.daysMask);
            await m.addColumn(medications, medications.startDay);
            await m.addColumn(medications, medications.endDay);
          }
          if (from < 4) {
            await m.createTable(profiles);
            await m.addColumn(medications, medications.profileId);
            // Eski ilaçlar profileId = 1 ile bu profile bağlanır
            await _insertSelfProfile();
          }
        },
        beforeOpen: (details) async {
          // Silinen ilacın saatleri ve kayıtları da silinsin diye
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA busy_timeout = 5000');
        },
      );

  Future<void> _insertSelfProfile() {
    return into(profiles).insert(ProfilesCompanion.insert(
      colorValue: profileColors.first,
      isSelf: const Value(true),
    ));
  }

  // ---------- Profiller ----------

  Stream<List<Profile>> watchProfiles() {
    return (select(profiles)..orderBy([(p) => OrderingTerm.asc(p.id)]))
        .watch();
  }

  Future<int> addProfile(String name, int colorValue) {
    return into(profiles).insert(
      ProfilesCompanion.insert(name: Value(name), colorValue: colorValue),
    );
  }

  Future<void> updateProfile(int id, String name, int colorValue) {
    return (update(profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(name: Value(name), colorValue: Value(colorValue)),
    );
  }

  /// "Ben" profili silinemez. Diğer profillerin ilaçları da birlikte silinir.
  Future<void> deleteProfile(int id) {
    return transaction(() async {
      final p = await (select(profiles)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (p == null || p.isSelf) return;
      await (delete(medications)..where((m) => m.profileId.equals(id))).go();
      await (delete(profiles)..where((t) => t.id.equals(id))).go();
    });
  }

  // ---------- İlaçlar ----------

  Future<void> addMedication({
    required String name,
    required String dose,
    required List<int> minutes,
    required bool useAlarm,
    required int daysMask,
    required int startDay,
    required int? endDay,
    required int profileId,
  }) {
    return transaction(() async {
      final id = await into(medications).insert(
        MedicationsCompanion.insert(
          name: name,
          dose: Value(dose),
          useAlarm: Value(useAlarm),
          daysMask: Value(daysMask),
          startDay: Value(startDay),
          endDay: Value(endDay),
          profileId: Value(profileId),
        ),
      );
      for (final m in minutes) {
        await into(reminders).insert(
          RemindersCompanion.insert(medicationId: id, minuteOfDay: m),
        );
      }
    });
  }

  Future<void> deleteMedication(int medicationId) {
    return (delete(medications)..where((m) => m.id.equals(medicationId))).go();
  }

    /// Düzenleme ekranı için ilaç ve saatleri
  Future<({Medication med, List<int> minutes})?> getMedicationForEdit(
      int id) async {
    final med = await (select(medications)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (med == null) return null;
    final rems = await (select(reminders)
          ..where((r) => r.medicationId.equals(id))
          ..orderBy([(r) => OrderingTerm.asc(r.minuteOfDay)]))
        .get();
    return (med: med, minutes: rems.map((r) => r.minuteOfDay).toList());
  }

  /// Aynı kalan saatlerin kayıtları (alındı geçmişi) korunur,
  /// kaldırılan saatlerin geçmişi silinir, yeni saatler eklenir.
  Future<void> updateMedication({
    required int id,
    required String name,
    required String dose,
    required List<int> minutes,
    required bool useAlarm,
    required int daysMask,
    required int startDay,
    required int? endDay,
    required int profileId,
  }) {
    return transaction(() async {
      await (update(medications)..where((m) => m.id.equals(id))).write(
        MedicationsCompanion(
          name: Value(name),
          dose: Value(dose),
          useAlarm: Value(useAlarm),
          daysMask: Value(daysMask),
          startDay: Value(startDay),
          endDay: Value(endDay),
          profileId: Value(profileId),
        ),
      );

      final existing = await (select(reminders)
            ..where((r) => r.medicationId.equals(id)))
          .get();
      final keep = <int>{};
      for (final r in existing) {
        if (minutes.contains(r.minuteOfDay)) {
          keep.add(r.minuteOfDay);
        } else {
          await (delete(reminders)..where((t) => t.id.equals(r.id))).go();
        }
      }
      for (final m in minutes) {
        if (!keep.contains(m)) {
          await into(reminders).insert(
            RemindersCompanion.insert(medicationId: id, minuteOfDay: m),
          );
        }
      }
    });
  }

  Future<void> markTaken(int reminderId, int dayKey) {
    return into(intakeLogs).insert(
      IntakeLogsCompanion.insert(
        reminderId: reminderId,
        dayKey: dayKey,
        takenAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> unmarkTaken(int reminderId, int dayKey) {
    return (delete(intakeLogs)
          ..where(
              (l) => l.reminderId.equals(reminderId) & l.dayKey.equals(dayKey)))
        .go();
  }

  /// Seçili profilin o günkü dozları, saate göre sıralı
  Stream<List<DoseItem>> watchDoses(int dayKey, int profileId) {
    final query = select(reminders).join([
      innerJoin(medications, medications.id.equalsExp(reminders.medicationId)),
      leftOuterJoin(
        intakeLogs,
        intakeLogs.reminderId.equalsExp(reminders.id) &
            intakeLogs.dayKey.equals(dayKey),
      ),
    ])
      ..where(medications.isActive.equals(true) &
          medications.profileId.equals(profileId))
      ..orderBy([OrderingTerm.asc(reminders.minuteOfDay)]);

    return query.watch().map((rows) => rows
        .where((row) => isMedicationDueOn(row.readTable(medications), dayKey))
        .map((row) {
      final med = row.readTable(medications);
      final rem = row.readTable(reminders);
      final log = row.readTableOrNull(intakeLogs);
      return DoseItem(
        reminderId: rem.id,
        medicationId: med.id,
        name: med.name,
        dose: med.dose,
        minuteOfDay: rem.minuteOfDay,
        taken: log != null,
      );
    }).toList());
  }

  /// Bildirim planlamak için tüm profillerin aktif ilaç saatleri
  Stream<List<ScheduleItem>> watchSchedules() {
    final query = select(reminders).join([
      innerJoin(medications, medications.id.equalsExp(reminders.medicationId)),
      innerJoin(profiles, profiles.id.equalsExp(medications.profileId)),
    ])
      ..where(medications.isActive.equals(true));

    return query.watch().map((rows) => rows.map((row) {
          final med = row.readTable(medications);
          final rem = row.readTable(reminders);
          final prof = row.readTable(profiles);
          return ScheduleItem(
            reminderId: rem.id,
            name: med.name,
            dose: med.dose,
            minuteOfDay: rem.minuteOfDay,
            useAlarm: med.useAlarm,
            daysMask: med.daysMask,
            startDay:
                med.startDay != 0 ? med.startDay : dayKeyOf(med.createdAt),
            endDay: med.endDay,
            profileId: prof.id,
            profileName: prof.name,
          );
        }).toList());
  }
}