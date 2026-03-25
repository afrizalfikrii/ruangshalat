import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Countdown target: next Fajr prayer (static demo, 06h 39m 28s remaining)
  Duration _remaining = const Duration(hours: 6, minutes: 39, seconds: 28);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final int hours = _remaining.inHours;
    final int minutes = _remaining.inMinutes.remainder(60);
    final int seconds = _remaining.inSeconds.remainder(60);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Location & Date ──────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.emeraldGreen, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'Karanganyar, Indonesia',
                    style: TextStyle(
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
                    'Kamis, 19 Mar 2026 / 1 Ramadhan 1447H',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Next Prayer Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    // Label
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

                    // Prayer Name + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'FAJR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'الفجر',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              '04:32',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'WIB',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Flip-clock countdown
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.white54, size: 16),
                        const SizedBox(width: 8),
                        _countdownBox(_twoDigits(hours), 'HR'),
                        _separator(),
                        _countdownBox(_twoDigits(minutes), 'MIN'),
                        _separator(),
                        _countdownBox(_twoDigits(seconds), 'DTK'),
                        const SizedBox(width: 10),
                        const Text(
                          'Left',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Prayer Schedule Header ───────────────────────────────────
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
                    'Kamis, 19 Mar',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Prayer List ──────────────────────────────────────────────
              Container(
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
                  children: [
                    _buildPrayerRow(
                        name: 'Fajr',
                        arabic: 'الفجر',
                        time: '04:32',
                        isNext: true,
                        dotColor: AppColors.emeraldGreen,
                        alarmOn: true),
                    _divider(),
                    _buildPrayerRow(
                        name: 'Dhuhr',
                        arabic: 'الظهر',
                        time: '11:58',
                        isNext: false,
                        dotColor: AppColors.gold,
                        alarmOn: false),
                    _divider(),
                    _buildPrayerRow(
                        name: 'Asr',
                        arabic: 'العصر',
                        time: '15:18',
                        isNext: false,
                        dotColor: AppColors.gold,
                        alarmOn: false),
                    _divider(),
                    _buildPrayerRow(
                        name: 'Maghrib',
                        arabic: 'المغرب',
                        time: '17:48',
                        isNext: false,
                        dotColor: AppColors.gold,
                        alarmOn: false),
                    _divider(),
                    _buildPrayerRow(
                        name: 'Isha',
                        arabic: 'العشاء',
                        time: '18:59',
                        isNext: false,
                        dotColor: AppColors.gold,
                        alarmOn: false,
                        isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Footer ───────────────────────────────────────────────────
              Center(
                child: Text(
                  'Berdasarkan metode Kemenag RI · Karanganyar',
                  style: TextStyle(
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
    );
  }

  // Countdown box widget
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
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14, left: 4, right: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildPrayerRow({
    required String name,
    required String arabic,
    required String time,
    required bool isNext,
    required Color dotColor,
    required bool alarmOn,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 12,
        bottom: isLast ? 12 : 12,
      ),
      child: Row(
        children: [
          // Colored dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),

          // Name + Arabic
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
                        color: Colors.black87,
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
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),

          // Time
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),

          // Bell icon
          Icon(
            alarmOn
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: alarmOn ? AppColors.emeraldGreen : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }
}
