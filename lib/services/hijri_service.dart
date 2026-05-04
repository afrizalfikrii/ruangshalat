import 'dart:convert';
import 'package:http/http.dart' as http;

class HijriDayInfo {
  final String gregorianDate;
  final String hijriDay;
  final String hijriMonthEn;
  final String hijriMonthAr;
  final String hijriYear;
  final List<String> holidays;

  const HijriDayInfo({
    required this.gregorianDate,
    required this.hijriDay,
    required this.hijriMonthEn,
    required this.hijriMonthAr,
    required this.hijriYear,
    required this.holidays,
  });

  String get hijriFullDate => '$hijriDay $hijriMonthEn $hijriYear H';

  static HijriDayInfo fromJson(Map<String, dynamic> json) {
    final hijri = json['hijri'] as Map<String, dynamic>;
    final gregorian = json['gregorian'] as Map<String, dynamic>;
    final holidays =
        (hijri['holidays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return HijriDayInfo(
      gregorianDate: gregorian['date'] as String,
      hijriDay: hijri['day'] as String,
      hijriMonthEn: (hijri['month'] as Map<String, dynamic>)['en'] as String,
      hijriMonthAr: (hijri['month'] as Map<String, dynamic>)['ar'] as String,
      hijriYear: hijri['year'] as String,
      holidays: holidays,
    );
  }
}

class HijriService {
  static const String _base = 'https://api.aladhan.com/v1';

  static Future<HijriDayInfo?> getTodayHijri() async {
    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final uri = Uri.parse('$_base/gToH/$date');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['code'] == 200) {
          return HijriDayInfo.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<DateTime, HijriDayInfo>> getMonthCalendar(
      int month, int year) async {
    try {
      final uri = Uri.parse('$_base/gToHCalendar/$month/$year');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['code'] == 200) {
          final dataList = body['data'] as List<dynamic>;
          final Map<DateTime, HijriDayInfo> result = {};
          for (final item in dataList) {
            final info = HijriDayInfo.fromJson(item as Map<String, dynamic>);
            final parts = info.gregorianDate.split('-');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]);
              final mon = int.tryParse(parts[1]);
              final yr = int.tryParse(parts[2]);
              if (day != null && mon != null && yr != null) {
                final key = DateTime(yr, mon, day);
                result[key] = info;
              }
            }
          }
          return result;
        }
      }
    } catch (_) {}
    return {};
  }
}
