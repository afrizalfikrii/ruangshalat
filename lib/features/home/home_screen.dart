import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/models/prayer_schedule.dart';
import 'package:ruang_shalat/services/myquran_service.dart';
import 'package:ruang_shalat/services/notification_service.dart';
import 'package:ruang_shalat/services/hijri_service.dart';
import 'package:ruang_shalat/features/qibla/qibla_ar_screen.dart';
import 'package:ruang_shalat/features/calendar/hijri_calendar_screen.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerSchedule? _schedule;
  bool _loading = true;
  String? _error;
  Duration _remaining = Duration.zero;
  late Timer _timer;

  SharedPreferences? _prefs;
  
  // Status notifikasi diubah menjadi String: 'audio', 'silent', 'off'
  final Map<String, String> _notificationSettings = {
    'Subuh': 'off',
    'Dzuhur': 'off',
    'Ashar': 'off',
    'Maghrib': 'off',
    'Isya': 'off',
  };

  final Map<String, String?> _prayerLogs = {
    'Subuh': null,
    'Dzuhur': null,
    'Ashar': null,
    'Maghrib': null,
    'Isya': null,
  };

  String _currentKotaId = '1411';
  String _currentKotaName = 'Mencari lokasi...';
  String _todayHijri = '';
  
  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initLocationAndFetchSchedule();
    _fetchTodayHijri();
    _fetchDailyLog();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_schedule != null && mounted) {
        setState(() => _remaining = _schedule!.durationUntilNext());
      }
    });
  }

  Future<void> _fetchDailyLog() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final data = await Supabase.instance.client
          .from('daily_logs')
          .select()
          .eq('user_id', user.id)
          .eq('log_date', today)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _prayerLogs['Subuh'] = data['subuh'];
          _prayerLogs['Dzuhur'] = data['dzuhur'];
          _prayerLogs['Ashar'] = data['asar'];
          _prayerLogs['Maghrib'] = data['maghrib'];
          _prayerLogs['Isya'] = data['isya'];
        });
      }
    } catch (e) {
      debugPrint('Error memuat log ibadah: $e');
    }
  }

  Future<void> _togglePrayerLog(String name, String timeString) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masuk melalui menu Profil untuk mulai mencatat progres ibadah Anda.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentStatus = _prayerLogs[name];

    if (currentStatus != null) {
      _saveLogToSupabase(name, null);
      return;
    }

    final now = DateTime.now();
    final parts = timeString.split(':');
    DateTime? prayerTime;
    
    if (parts.length == 2) {
      prayerTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    }

    if (prayerTime != null && now.isBefore(prayerTime)) {
      if (name == 'Subuh' || name == 'Dzuhur' || name == 'Maghrib') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waktu $name belum masuk. Shalat ini tidak bisa di-Jamak Taqdim.'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      String jamakWith = name == 'Ashar' ? 'Dzuhur' : 'Maghrib';
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Waktu Belum Masuk', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text('Waktu shalat $name belum tiba. Apakah Anda mencatat ini untuk Jamak Taqdim dengan $jamakWith?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Jamak'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        _saveLogToSupabase(name, 'JAMAK');
      }
      return;
    }

    final selectedStatus = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat Shalat $name',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.emeraldGreen),
                  title: const Text('Tepat Waktu'),
                  subtitle: const Text('Shalat pada waktunya'),
                  onTap: () => Navigator.pop(context, 'TEPAT_WAKTU'),
                ),
                
                if (name != 'Subuh')
                  ListTile(
                    leading: const Icon(Icons.sync_alt, color: Colors.blue),
                    title: const Text('Jamak'),
                    subtitle: Text(name == 'Dzuhur' || name == 'Ashar' 
                        ? 'Digabung Dzuhur & Ashar' 
                        : 'Digabung Maghrib & Isya'),
                    onTap: () => Navigator.pop(context, 'JAMAK'),
                  ),
                  
                ListTile(
                  leading: const Icon(Icons.history, color: AppColors.gold),
                  title: const Text('Qadha'),
                  subtitle: const Text('Mengganti shalat yang terlewat'),
                  onTap: () => Navigator.pop(context, 'QADHA'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedStatus != null) {
      _saveLogToSupabase(name, selectedStatus);
    }
  }

  // ==============================================================================
  // --- FUNGSI UPDATE: MENYIMPAN LOG DAN MENGHITUNG STREAK/POIN SECARA OTOMATIS --
  // ==============================================================================
  Future<void> _saveLogToSupabase(String name, String? status) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final previousStatus = _prayerLogs[name];

    // Update UI Lokal
    setState(() {
      _prayerLogs[name] = status;
    });

    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    try {
      // 1. Simpan Log Shalat Harian
      await Supabase.instance.client.from('daily_logs').upsert({
        'user_id': user.id,
        'log_date': todayStr,
        'subuh': _prayerLogs['Subuh'],
        'dzuhur': _prayerLogs['Dzuhur'],
        'asar': _prayerLogs['Ashar'],
        'maghrib': _prayerLogs['Maghrib'],
        'isya': _prayerLogs['Isya'],
      }, onConflict: 'user_id, log_date');

      // 2. Ambil Profil Saat Ini untuk kalkulasi Poin dan Streak
      final profile = await Supabase.instance.client.from('profiles').select().eq('id', user.id).single();
      
      int currentStreak = profile['current_streak'] ?? 0;
      int longestStreak = profile['longest_streak'] ?? 0;
      int totalPoints = profile['total_points'] ?? 0;

      // Cek kelengkapan hari kemarin
      final yesterdayLog = await Supabase.instance.client
          .from('daily_logs')
          .select()
          .eq('user_id', user.id)
          .eq('log_date', yesterdayStr)
          .maybeSingle();

      bool wasYesterdayComplete = false;
      if (yesterdayLog != null) {
        if (yesterdayLog['subuh'] != null && yesterdayLog['dzuhur'] != null &&
            yesterdayLog['asar'] != null && yesterdayLog['maghrib'] != null &&
            yesterdayLog['isya'] != null) {
          wasYesterdayComplete = true;
        }
      }

      // HUKUMAN: Reset Streak jika kemarin bolong (dan bukan streak awal/0)
      if (!wasYesterdayComplete && currentStreak > 0) {
        currentStreak = 0; 
      }

      // Cek kelengkapan hari ini
      bool isTodayComplete = _prayerLogs['Subuh'] != null && _prayerLogs['Dzuhur'] != null && 
                             _prayerLogs['Ashar'] != null && _prayerLogs['Maghrib'] != null && 
                             _prayerLogs['Isya'] != null;

      // REWARD: Jika hari ini komplit DAN sebelumnya statusnya null (baru ditambahkan, bukan mengedit)
      // Ini mencegah eksploitasi di mana user terus mengubah status shalat yang sama untuk menaikkan poin/streak.
      if (isTodayComplete && status != null && previousStatus == null) {
        currentStreak += 1;
        totalPoints += 50; 

        if (currentStreak > longestStreak) {
          longestStreak = currentStreak; 
        }
      } 
      // Jika pengguna membatalkan shalat terakhir (menjadi tidak lengkap), kurangi streak agar adil.
      else if (!isTodayComplete && status == null && currentStreak > 0) {
        // Asumsi: jika sebelumnya dia mencabut komplitnya, maka kita kurangi 1.
        // Poin bisa tetap, atau Anda bisa mengatur logika pengurangan poin. Untuk saat ini kita kurangi streak.
        currentStreak -= 1;
      }

      // 3. Simpan Kalkulasi Gamifikasi ke Tabel Profil
      await Supabase.instance.client.from('profiles').update({
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_points': totalPoints,
      }).eq('id', user.id);

    } catch (e) {
      // Revert UI jika gagal
      setState(() {
        _prayerLogs[name] = previousStatus;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan catatan: $e')),
        );
      }
    }
  }

  Future<void> _fetchTodayHijri() async {
    final info = await HijriService.getTodayHijri();
    if (info != null && mounted) {
      setState(() => _todayHijri = info.hijriFullDate);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // --- MIGRASI & BACA PENGATURAN NOTIFIKASI ---
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationSettings['Subuh'] = _getPrefString('Subuh');
      _notificationSettings['Dzuhur'] = _getPrefString('Dzuhur');
      _notificationSettings['Ashar'] = _getPrefString('Ashar');
      _notificationSettings['Maghrib'] = _getPrefString('Maghrib');
      _notificationSettings['Isya'] = _getPrefString('Isya');

      final savedKotaId = _prefs?.getString('kotaId');
      final savedKotaName = _prefs?.getString('kotaName');
      if (savedKotaId != null && savedKotaName != null) {
        _currentKotaId = savedKotaId;
        _currentKotaName = savedKotaName;
      }
      
      _lastLat = _prefs?.getDouble('lastLat');
      _lastLng = _prefs?.getDouble('lastLng');
    });
  }

  String _getPrefString(String prayerName) {
    final newKey = 'notif_status_$prayerName';
    final oldKey = 'notif_$prayerName';
    
    final newStatus = _prefs?.getString(newKey);
    if (newStatus != null) return newStatus;
    
    // Migrasi data lama dari boolean ke string (default: silent jika dulu aktif)
    try {
      final oldStatus = _prefs?.getBool(oldKey);
      if (oldStatus == true) return 'silent'; 
    } catch (e) {
      // Abaikan jika error
    }
    return 'off';
  }

  // --- MENU PILIHAN STATUS NOTIFIKASI (BOTTOM SHEET) ---
  Future<void> _showNotificationOptions(String prayerName, String time) async {
    final currentStatus = _notificationSettings[prayerName] ?? 'off';
    final isSubuh = prayerName == 'Subuh';

    final selectedOption = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi $prayerName',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: AppColors.emeraldGreen),
                  title: const Text('Suara Adzan', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(isSubuh ? 'Lantunan adzan khusus Subuh' : 'Lantunan adzan standar'),
                  trailing: currentStatus == 'audio' ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen) : null,
                  onTap: () => Navigator.pop(context, 'audio'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: const Text('Notifikasi Saja', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Hanya pesan teks dan getar'),
                  trailing: currentStatus == 'silent' ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                  onTap: () => Navigator.pop(context, 'silent'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
                  title: const Text('Nonaktif', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Matikan pengingat shalat ini'),
                  trailing: currentStatus == 'off' ? const Icon(Icons.check_circle, color: Colors.grey) : null,
                  onTap: () => Navigator.pop(context, 'off'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedOption != null && selectedOption != currentStatus) {
      await _applyNotificationSetting(prayerName, time, selectedOption);
    }
  }

  Future<void> _applyNotificationSetting(String prayerName, String time, String status) async {
    setState(() {
      _notificationSettings[prayerName] = status;
    });

    if (_prefs != null) {
      await _prefs!.setString('notif_status_$prayerName', status);
    }

    final id = _getPrayerId(prayerName);

    if (status == 'off') {
      await NotificationService().cancelNotification(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengingat $prayerName dinonaktifkan')),
        );
      }
    } else {
      final now = DateTime.now();
      final parts = time.split(':');
      if (parts.length == 2) {
        DateTime scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        await NotificationService().schedulePrayerNotification(
          id: id,
          title: 'Waktunya Shalat $prayerName',
          body: 'Telah masuk waktu shalat $prayerName wilayah $_currentKotaName.',
          scheduledTime: scheduledTime,
          prayerName: prayerName, 
          status: status,         
        );

        if (mounted) {
          String msg = status == 'audio' ? 'Suara Adzan' : 'Notifikasi teks';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$msg diaktifkan untuk $prayerName')),
          );
        }
      }
    }
  }

  int _getPrayerId(String name) {
    switch (name) {
      case 'Subuh': return 1;
      case 'Dzuhur': return 2;
      case 'Ashar': return 3;
      case 'Maghrib': return 4;
      case 'Isya': return 5;
      default: return 0;
    }
  }

  Future<void> _initLocationAndFetchSchedule() async {
    if (!mounted) return;

    if (_prefs?.getString('kotaId') != null) {
      await _fetchSchedule();
      _forceUpdateLocation();
      return;
    }

    await _forceUpdateLocation();
  }

  Future<void> _forceUpdateLocation() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _currentKotaName = 'Mencari lokasi...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS dinonaktifkan.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen.');
      }

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ));

      _lastLat = position.latitude;
      _lastLng = position.longitude;
      await _prefs?.setDouble('lastLat', _lastLat!);
      await _prefs?.setDouble('lastLng', _lastLng!);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String cityName =
            place.subAdministrativeArea ?? place.locality ?? 'Jakarta';
        cityName = cityName
            .replaceAll('Kab. ', '')
            .replaceAll('Kabupaten ', '')
            .replaceAll('Kota ', '')
            .trim();

        List<KotaResult> searchResults =
            await MyQuranService.searchKota(cityName);
        if (searchResults.isNotEmpty) {
          _currentKotaId = searchResults.first.id;
          _currentKotaName = searchResults.first.lokasi;

          await _prefs?.setString('kotaId', _currentKotaId);
          await _prefs?.setString('kotaName', _currentKotaName);
        } else {
          _currentKotaName = cityName;
        }
      }
    } catch (e) {
      _currentKotaId = '1411';
      _currentKotaName = 'Karanganyar';
    }

    await _fetchSchedule();
  }

  PrayerSchedule? _getOfflineSchedule(double lat, double lng, DateTime date) {
    try {
      final coordinates = Coordinates(lat, lng);
      // Gunakan parameter Singapore (yang paling mendekati wilayah Asia Tenggara/Indonesia)
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayerTimes = PrayerTimes.today(coordinates, params);
      final f = DateFormat('HH:mm');
      
      return PrayerSchedule(
        imsak: f.format(prayerTimes.fajr.subtract(const Duration(minutes: 10))),
        subuh: f.format(prayerTimes.fajr),
        terbit: f.format(prayerTimes.sunrise),
        dhuha: f.format(prayerTimes.sunrise.add(const Duration(minutes: 20))),
        dzuhur: f.format(prayerTimes.dhuhr),
        ashar: f.format(prayerTimes.asr),
        maghrib: f.format(prayerTimes.maghrib),
        isya: f.format(prayerTimes.isha),
        tanggal: DateFormat('yyyy-MM-dd').format(date),
        date: DateFormat('yyyy-MM-dd').format(date),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    
    PrayerSchedule? schedule = await MyQuranService.getPrayerSchedule(
      kotaId: _currentKotaId,
      date: DateTime.now(),
    );
    
    // --- OFFLINE FALLBACK ---
    if (schedule == null && _lastLat != null && _lastLng != null) {
       schedule = _getOfflineSchedule(_lastLat!, _lastLng!, DateTime.now());
       if (schedule != null && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Tidak ada internet. Menampilkan jadwal sholat offline.'),
             backgroundColor: Colors.orange,
             behavior: SnackBarBehavior.floating,
             duration: Duration(seconds: 3),
           ),
         );
       }
    }

    if (!mounted) return;
    setState(() {
      _schedule = schedule;
      _loading = false;
      _error = schedule == null ? 'Gagal memuat jadwal.' : null;
      if (schedule != null) _remaining = schedule.durationUntilNext();
    });
    
    _fetchDailyLog(); // Reload status tiap update lokasi
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'ruangShalat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.emeraldGreen,
        onRefresh: _fetchSchedule,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Memperbarui lokasi GPS...')),
                              );
                              _forceUpdateLocation();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.emeraldGreen, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _currentKotaName,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.refresh,
                                    color: Colors.grey, size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HijriCalendarScreen()),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.calendar_today_outlined,
                                      color: AppColors.emeraldGreen, size: 14),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _schedule?.tanggal ?? _formatDateFallback(),
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      if (_todayHijri.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _todayHijri,
                                          style: const TextStyle(
                                            color: AppColors.emeraldGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QiblaArScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.emeraldGreen, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.emeraldGreen.withValues(alpha: 0.06),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.explore,
                                color: AppColors.emeraldGreen, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Kiblat',
                              style: TextStyle(
                                color: AppColors.emeraldGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _loading
                    ? _buildLoadingCard()
                    : _error != null
                        ? _buildErrorCard()
                        : _buildNextPrayerCard(),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadwal Shalat Hari Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _formatDateShort(),
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _loading
                    ? _buildListSkeleton()
                    : _error != null
                        ? const SizedBox()
                        : _buildPrayerList(),

                const SizedBox(height: 14),

                Center(
                  child: Text(
                    'Berdasarkan data Kemenag RI · $_currentKotaName',
                    style: const TextStyle(
                      color: AppColors.emeraldGreen,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final next = _schedule!.nextPrayer()!;
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.emeraldGreen, AppColors.emeraldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SHALAT BERIKUTNYA',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    next.arabic,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    next.time,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'WIB',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              _countdownBox(_twoDigits(h), 'HR'),
              _separator(),
              _countdownBox(_twoDigits(m), 'MIN'),
              _separator(),
              _countdownBox(_twoDigits(s), 'DTK'),
              const SizedBox(width: 10),
              const Text('Tersisa',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList() {
    final s = _schedule!;
    final now = DateTime.now();

    final prayers = [
      _PrayerEntry(name: 'Subuh', arabic: 'الفجر', time: s.subuh),
      _PrayerEntry(name: 'Dzuhur', arabic: 'الظهر', time: s.dzuhur),
      _PrayerEntry(name: 'Ashar', arabic: 'العصر', time: s.ashar),
      _PrayerEntry(name: 'Maghrib', arabic: 'المغرب', time: s.maghrib),
      _PrayerEntry(name: 'Isya', arabic: 'العشاء', time: s.isya),
    ];

    final nextName = s.nextPrayer()?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: prayers.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final isNext = p.name == nextName;

          final parts = p.time.split(':');
          bool hasPassed = false;
          if (parts.length == 2) {
            final pTime = DateTime(now.year, now.month, now.day,
                int.parse(parts[0]), int.parse(parts[1]));
            hasPassed = now.isAfter(pTime);
          }

          return Column(
            children: [
              _buildPrayerRow(
                name: p.name,
                arabic: p.arabic,
                time: p.time,
                isNext: isNext,
                hasPassed: hasPassed,
                isLast: i == prayers.length - 1,
              ),
              if (i < prayers.length - 1)
                Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerRow({
    required String name,
    required String arabic,
    required String time,
    required bool isNext,
    required bool hasPassed,
    bool isLast = false,
  }) {
    final logStatus = _prayerLogs[name];
    final isChecked = logStatus != null; 
    
    // Mengambil status notifikasi
    final notifStatus = _notificationSettings[name] ?? 'off';

    final dotColor = isNext
        ? AppColors.emeraldGreen
        : hasPassed
            ? Colors.grey.shade300
            : AppColors.gold;

    Color checkboxColor = Colors.transparent;
    if (isChecked) {
      if (logStatus == 'TEPAT_WAKTU') {
        checkboxColor = AppColors.emeraldGreen;
      } else if (logStatus == 'JAMAK') {
        checkboxColor = Colors.blue; 
      } else if (logStatus == 'QADHA') {
        checkboxColor = AppColors.gold; 
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.w500,
                        color: hasPassed && !isNext
                            ? Colors.grey.shade400
                            : Colors.black87,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'BERIKUTNYA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  arabic,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              color: hasPassed && !isNext
                  ? Colors.grey.shade400
                  : Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          
          GestureDetector(
            onTap: () => _togglePrayerLog(name, time),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: checkboxColor,
                border: Border.all(
                  color: isChecked ? checkboxColor : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          
          const SizedBox(width: 4),
          
          // --- IKON NOTIFIKASI DINAMIS ---
          IconButton(
            icon: Icon(
              notifStatus == 'audio' 
                  ? Icons.notifications_active 
                  : notifStatus == 'silent' 
                      ? Icons.notifications 
                      : Icons.notifications_off_outlined,
              color: notifStatus == 'audio' 
                  ? AppColors.emeraldGreen 
                  : notifStatus == 'silent' 
                      ? Colors.blue 
                      : Colors.grey.shade400,
              size: 22,
            ),
            splashRadius: 20,
            onPressed: () => _showNotificationOptions(name, time),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.emeraldGreen, AppColors.emeraldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(height: 12),
            Text('Memuat jadwal shalat...',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off, color: Colors.red.shade400, size: 36),
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _fetchSchedule,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(5, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _shimmer(10, 10, radius: 5),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmer(80, 12, radius: 4),
                          const SizedBox(height: 4),
                          _shimmer(50, 10, radius: 4),
                        ],
                      ),
                    ),
                    _shimmer(40, 14, radius: 4),
                  ],
                ),
              ),
              if (i < 4)
                Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  Widget _shimmer(double w, double h, {double radius = 4}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _countdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(38),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14, left: 4, right: 4),
      child: Text(':',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDateFallback() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatDateShort() {
    final now = DateTime.now();
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _PrayerEntry {
  final String name, arabic, time;
  const _PrayerEntry(
      {required this.name, required this.arabic, required this.time});
}