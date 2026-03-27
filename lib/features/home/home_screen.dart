import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/models/prayer_schedule.dart';
import 'package:ruang_shalat/services/myquran_service.dart';
import 'package:ruang_shalat/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  PrayerSchedule? _schedule;
  bool _loading = true;
  String? _error;
  Duration _remaining = Duration.zero;
  late Timer _timer;
  
  SharedPreferences? _prefs;
  final Map<String, bool> _activeNotifications = {};

  // Default city: Karanganyar (id: 1411 from kemenag / myquran API)
  // We'll search dynamically; default to kota terdekat
  static const _defaultKotaId = '1411'; // Karanganyar
  static const _defaultKotaName = 'Karanganyar';

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _fetchSchedule();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_schedule != null && mounted) {
        setState(() => _remaining = _schedule!.durationUntilNext());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeNotifications['Subuh'] = _prefs?.getBool('notif_Subuh') ?? false;
      _activeNotifications['Dzuhur'] = _prefs?.getBool('notif_Dzuhur') ?? false;
      _activeNotifications['Ashar'] = _prefs?.getBool('notif_Ashar') ?? false;
      _activeNotifications['Maghrib'] = _prefs?.getBool('notif_Maghrib') ?? false;
      _activeNotifications['Isya'] = _prefs?.getBool('notif_Isya') ?? false;
    });
  }

  Future<void> _toggleNotification(String prayerName, String time) async {
    final bool isCurrentlyActive = _activeNotifications[prayerName] ?? false;
    final bool willBeActive = !isCurrentlyActive;

    setState(() {
      _activeNotifications[prayerName] = willBeActive;
    });

    if (_prefs != null) {
      await _prefs!.setBool('notif_$prayerName', willBeActive);
    }

    final id = _getPrayerId(prayerName);

    if (willBeActive) {
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
          body: 'Telah masuk waktu shalat $prayerName wilayah $_defaultKotaName.',
          scheduledTime: scheduledTime,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notifikasi shalat $prayerName diaktifkan')),
          );
        }
      }
    } else {
      await NotificationService().cancelNotification(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifikasi shalat $prayerName dimatikan')),
        );
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

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final schedule = await MyQuranService.getPrayerSchedule(
      kotaId: _defaultKotaId,
      date: DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _schedule = schedule;
      _loading = false;
      _error = schedule == null ? 'Gagal memuat jadwal. Cek koneksi internet.' : null;
      if (schedule != null) _remaining = schedule.durationUntilNext();
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 12,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 20),
          ),
        ),
        title: const Text(
          'Ruang Shalat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Colors.black87, size: 26),
            onPressed: () {},
          ),
        ],
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
                // ── Location & Date ─────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.emeraldGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _defaultKotaName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _schedule?.tanggal ?? _formatDateFallback(),
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Next Prayer Card ─────────────────────────────────────
                _loading
                    ? _buildLoadingCard()
                    : _error != null
                        ? _buildErrorCard()
                        : _buildNextPrayerCard(),
                const SizedBox(height: 20),

                // ── Prayer Schedule Header ───────────────────────────────
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

                // ── Prayer List ──────────────────────────────────────────
                _loading
                    ? _buildListSkeleton()
                    : _error != null
                        ? const SizedBox()
                        : _buildPrayerList(),

                const SizedBox(height: 14),

                // ── Footer ───────────────────────────────────────────────
                Center(
                  child: Text(
                    'Berdasarkan data Kemenag RI · $_defaultKotaName',
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

  // ── Next Prayer Card ───────────────────────────────────────────────────────
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
              const Text('Left',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Prayer List ──────────────────────────────────────────────────────────
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

          // Determine if prayer has passed
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
                isNotifActive: _activeNotifications[p.name] ?? false,
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
    required bool isNotifActive,
  }) {
    final dotColor = isNext
        ? AppColors.emeraldGreen
        : hasPassed
            ? Colors.grey.shade300
            : AppColors.gold;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
                    if (hasPassed && !isNext) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle,
                          size: 13, color: Colors.grey.shade400),
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
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              isNotifActive ? Icons.notifications_active : Icons.notifications_none_outlined,
              color: isNotifActive ? AppColors.emeraldGreen : Colors.grey.shade400,
              size: 22,
            ),
            splashRadius: 20,
            onPressed: () => _toggleNotification(name, time),
          ),
        ],
      ),
    );
  }

  // ── Loading & Error Widgets ────────────────────────────────────────────────
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

  // ── Countdown helpers ──────────────────────────────────────────────────────
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

  // ── Date helpers ───────────────────────────────────────────────────────────
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
