import 'package:flutter_test/flutter_test.dart';
import 'package:ruang_shalat/services/myquran_service.dart';

void main() {
  test('MyQuranService dapat mengambil jadwal shalat', () async {
    final kotas = await MyQuranService.searchKota('Karanganyar');
    expect(kotas, isNotEmpty);
    
    final schedule = await MyQuranService.getPrayerSchedule(
      kotaId: kotas.first.id,
      date: DateTime.now(),
    );
    
    expect(schedule, isNotNull);
    expect(schedule!.subuh, isNotEmpty);
    expect(schedule.dzuhur, isNotEmpty);
    
    print('Subuh: \${schedule.subuh}');
    print('Dzuhur: \${schedule.dzuhur}');
    print('API connection SUCCESS!');
  });
}
