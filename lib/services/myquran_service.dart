import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ruang_shalat/models/prayer_schedule.dart';
import 'package:ruang_shalat/models/quran_models.dart';

/// Central API service for myquran.com v2
class MyQuranService {
  static const String _base = 'https://api.myquran.com/v2';

  // ── Prayer Schedule ─────────────────────────────────────────────────────────

  /// Search kota by keyword, returns list of [KotaResult]
  static Future<List<KotaResult>> searchKota(String keyword) async {
    final url = Uri.parse(
      '$_base/sholat/kota/cari/${Uri.encodeComponent(keyword)}',
    );
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == true) {
          final data = json['data'] as List;
          return data.map((e) => KotaResult.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Get prayer schedule for a kota on a specific date
  static Future<PrayerSchedule?> getPrayerSchedule({
    required String kotaId,
    required DateTime date,
  }) async {
    final url = Uri.parse(
      '$_base/sholat/jadwal/$kotaId/${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
    );
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == true) {
          return PrayerSchedule.fromJson(json['data']);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── Al-Quran ────────────────────────────────────────────────────────────────

  /// Get full detail of a surah (info + tafsir etc.)
  static Future<Surah?> getSurah(int surahNo) async {
    final url = Uri.parse('$_base/quran/surat/$surahNo');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == true) {
          return Surah.fromJson(json);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Get all ayat of a surah from Equran.id (since myquran v2 lacks full-surah endpoint)
  static Future<List<Ayat>> getAyatBySurah(int surahNo, int ayatCount) async {
    final url = Uri.parse('https://equran.id/api/v2/surat/$surahNo');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['code'] == 200 && json['data'] != null) {
          final ayatList = json['data']['ayat'] as List;
          return ayatList.map((e) => Ayat.fromEquranJson(e, surahNo)).toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
