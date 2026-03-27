/// Models for myquran.com prayer schedule API response

class PrayerSchedule {
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String tanggal;
  final String date;

  const PrayerSchedule({
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.tanggal,
    required this.date,
  });

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    final jadwal = json['jadwal'] as Map<String, dynamic>;
    return PrayerSchedule(
      imsak: jadwal['imsak'] ?? '-',
      subuh: jadwal['subuh'] ?? '-',
      terbit: jadwal['terbit'] ?? '-',
      dhuha: jadwal['dhuha'] ?? '-',
      dzuhur: jadwal['dzuhur'] ?? '-',
      ashar: jadwal['ashar'] ?? '-',
      maghrib: jadwal['maghrib'] ?? '-',
      isya: jadwal['isya'] ?? '-',
      tanggal: jadwal['tanggal'] ?? '-',
      date: jadwal['date'] ?? '',
    );
  }

  /// Returns the next upcoming prayer name + time from now.
  /// Returns null if all prayers have passed today.
  ({String name, String arabic, String time})? nextPrayer() {
    final now = DateTime.now();

    final prayers = [
      (name: 'Subuh', arabic: 'الفجر', time: subuh),
      (name: 'Dzuhur', arabic: 'الظهر', time: dzuhur),
      (name: 'Ashar', arabic: 'العصر', time: ashar),
      (name: 'Maghrib', arabic: 'المغرب', time: maghrib),
      (name: 'Isya', arabic: 'العشاء', time: isya),
    ];

    for (final p in prayers) {
      final parts = p.time.split(':');
      if (parts.length == 2) {
        final pTime = DateTime(
            now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
        if (now.isBefore(pTime)) return (name: p.name, arabic: p.arabic, time: p.time);
      }
    }
    // All passed, return next Subuh
    return (name: 'Subuh', arabic: 'الفجر', time: subuh);
  }

  /// Duration until the next prayer.
  Duration durationUntilNext() {
    final next = nextPrayer();
    if (next == null) return Duration.zero;
    final now = DateTime.now();
    final parts = next.time.split(':');
    var target = DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }
}

/// Kota search result
class KotaResult {
  final String id;
  final String lokasi;
  const KotaResult({required this.id, required this.lokasi});

  factory KotaResult.fromJson(Map<String, dynamic> json) =>
      KotaResult(id: json['id'].toString(), lokasi: json['lokasi'] ?? '');
}
