import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/services/hijri_service.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, HijriDayInfo> _calendarData = {};
  bool _loading = true;

  final Map<String, String> _translationCache = {};

  Future<String> _getTranslation(String englishText) async {
    final clean = englishText.replaceAll(RegExp(r'\s*[\u0600-\u06FF]\s*$'), '').trim();
    if (_translationCache.containsKey(clean)) return _translationCache[clean]!;
    try {
      final encoded = Uri.encodeComponent(clean);
      final uri = Uri.parse(
          'https://api.mymemory.translated.net/get?q=$encoded&langpair=en|id');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final translated = data['responseData']?['translatedText'] as String?;
        if (translated != null &&
            translated.isNotEmpty &&
            translated.toLowerCase() != clean.toLowerCase()) {
          _translationCache[clean] = translated;
          return translated;
        }
      }
    } catch (_) {}
    return '';
  }

  Future<void> _translateVisibleHolidays() async {
    final allHolidays = _calendarData.values
        .expand((info) => info.holidays)
        .toSet()
        .toList();
    for (final h in allHolidays) {
      final clean = h.replaceAll(RegExp(r'\s*[\u0600-\u06FF]\s*$'), '').trim();
      if (!_translationCache.containsKey(clean)) {
        final result = await _getTranslation(h);
        if (result.isNotEmpty && mounted) setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID').then((_) {
      _fetchMonth(_focusedDay);
    });
  }

  Future<void> _fetchMonth(DateTime date) async {
    setState(() => _loading = true);
    final data = await HijriService.getMonthCalendar(date.month, date.year);
    if (mounted) {
      setState(() {
        _calendarData = data;
        _loading = false;
      });
      _translateVisibleHolidays();
    }
  }

  HijriDayInfo? _getInfo(DateTime day) {
    return _calendarData[DateTime(day.year, day.month, day.day)];
  }

  @override
  Widget build(BuildContext context) {
    final selectedInfo = _getInfo(_selectedDay);
    final today = DateTime.now();
    final todayInfo = _getInfo(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_ruangshalat.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kalender Hijriah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (todayInfo != null)
                  Text(
                    todayInfo.hijriFullDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendarHeader(),
            _buildCalendar(),
            const SizedBox(height: 16),
            _buildDetailPanel(selectedInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final info = _getInfo(DateTime(_focusedDay.year, _focusedDay.month, 1));
    final hijriMonthLabel = info != null
        ? '${info.hijriMonthAr} ${info.hijriYear} H'
        : '';

    if (hijriMonthLabel.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.emeraldGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          hijriMonthLabel,
          style: const TextStyle(
            color: AppColors.emeraldGreen,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _loading
          ? const SizedBox(
              height: 320,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.emeraldGreen),
              ),
            )
          : TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2099),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 56,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.emeraldGreen,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.emeraldGreen,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
                titleTextFormatter: (date, locale) {
                  final List<String> bulanList = [
                    'Januari',
                    'Februari',
                    'Maret',
                    'April',
                    'Mei',
                    'Juni',
                    'Juli',
                    'Agustus',
                    'September',
                    'Oktober',
                    'November',
                    'Desember',
                  ];
                  return '${bulanList[date.month - 1]} ${date.year}';
                },
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                weekendStyle: const TextStyle(
                  color: AppColors.emeraldGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                decoration: BoxDecoration(color: Colors.grey.shade50),
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 0,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  isSelected: false,
                  isToday: isSameDay(day, today),
                ),
                todayBuilder: (context, day, focusedDay) =>
                    _buildDayCell(day, isSelected: false, isToday: true),
                selectedBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  isSelected: true,
                  isToday: isSameDay(day, today),
                ),
                outsideBuilder: (context, day, focusedDay) => _buildDayCell(
                  day,
                  isSelected: false,
                  isToday: false,
                  isOutside: true,
                ),
              ),
              eventLoader: (day) {
                final info = _getInfo(day);
                if (info != null && info.holidays.isNotEmpty) return [true];
                return [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchMonth(focusedDay);
              },
            ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    required bool isSelected,
    required bool isToday,
    bool isOutside = false,
  }) {
    final info = _getInfo(day);
    final hijriDay = info?.hijriDay ?? '';
    final hasEvent = info != null && info.holidays.isNotEmpty;

    Color dateTextColor;
    Color hijriTextColor;
    Color? circleBg;
    Color? circleBorder;

    if (isSelected) {
      dateTextColor = Colors.white;
      hijriTextColor = Colors.grey.shade500;
      circleBg = AppColors.emeraldGreen;
      circleBorder = AppColors.emeraldGreen;
    } else if (isToday) {
      dateTextColor = AppColors.emeraldGreen;
      hijriTextColor = AppColors.emeraldGreen;
      circleBg = AppColors.emeraldGreen.withValues(alpha: 0.12);
      circleBorder = AppColors.emeraldGreen;
    } else if (isOutside) {
      dateTextColor = Colors.grey.shade300;
      hijriTextColor = Colors.grey.shade300;
    } else {
      dateTextColor = Colors.black87;
      hijriTextColor = Colors.grey.shade500;
    }

    final bool hasCircle = isSelected || isToday;

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: hasCircle
                  ? BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: circleBorder!,
                        width: isToday && !isSelected ? 1.5 : 0,
                      ),
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasCircle ? FontWeight.bold : FontWeight.w500,
                  color: dateTextColor,
                ),
              ),
            ),
            if (hijriDay.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  hijriDay,
                  style: TextStyle(
                    fontSize: 9,
                    color: hijriTextColor,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
        if (hasEvent)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFD4AF37),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailPanel(HijriDayInfo? info) {
    final List<String> hariList = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final List<String> bulanList = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final hari = hariList[(_selectedDay.weekday - 1) % 7];
    final bulan = bulanList[_selectedDay.month - 1];
    final dateLabel = '$hari, ${_selectedDay.day} $bulan ${_selectedDay.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.emeraldGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _loading
                            ? const Text(
                                'Memuat...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              )
                            : Text(
                                info?.hijriFullDate ?? 'Data tidak tersedia',
                                style: const TextStyle(
                                  color: AppColors.emeraldGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              if (info != null && info.hijriMonthAr.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    info.hijriMonthAr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.emeraldGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (info != null && info.holidays.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Hari Penting Islam',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...info.holidays.map(
            (holiday) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holiday,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B6000),
                          ),
                        ),
                        Builder(builder: (context) {
                          final clean = holiday
                              .replaceAll(RegExp(r'\s*[\u0600-\u06FF]\s*$'), '')
                              .trim();
                          final translation = _translationCache[clean];
                          if (translation == null || translation.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              translation,
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF7B6000).withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (!_loading) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tidak ada hari penting pada tanggal ini',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
