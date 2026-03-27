import 'package:ruang_shalat/services/myquran_service.dart';

void main() async {
  print('Mencari kota Karanganyar...');
  final kotas = await MyQuranService.searchKota('Karanganyar');
  if (kotas.isNotEmpty) {
    print('Kota ditemukan: \${kotas.first.lokasi} (ID: \${kotas.first.id})');
    
    final now = DateTime.now();
    print('Mengambil jadwal shalat untuk \${now.toIso8601String()}...');
    
    final schedule = await MyQuranService.getPrayerSchedule(
      kotaId: kotas.first.id,
      date: now,
    );
    
    if (schedule != null) {
      print('Jadwal Shalat:');
      print('Subuh: \${schedule.subuh}');
      print('Dzuhur: \${schedule.dzuhur}');
      print('Ashar: \${schedule.ashar}');
      print('Maghrib: \${schedule.maghrib}');
      print('Isya: \${schedule.isya}');
      print('Testing SUCCESS!');
    } else {
      print('Gagal mengambil jadwal shalat.');
    }
  } else {
    print('Kota Karanganyar tidak ditemukan.');
  }
}
