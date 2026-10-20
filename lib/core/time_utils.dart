String formatMinutes(int minuteOfDay) {
  final h = (minuteOfDay ~/ 60).toString().padLeft(2, '0');
  final m = (minuteOfDay % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// 2026-10-17 -> 20261017 (günü sayı olarak saklamak için)
int dayKeyOf(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

String doseLine(int minuteOfDay, String dose) => dose.isEmpty
    ? formatMinutes(minuteOfDay)
    : '${formatMinutes(minuteOfDay)} • $dose';

/// Gün maskesi: bit 0 = Pazartesi ... bit 6 = Pazar (DateTime.weekday 1..7)
bool maskHasDay(int mask, int weekday) => (mask >> (weekday - 1)) & 1 == 1;

DateTime dateOfDayKey(int k) => DateTime(k ~/ 10000, (k ~/ 100) % 100, k % 100);