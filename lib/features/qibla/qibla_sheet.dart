import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/services/qibla_service.dart';

class QiblaSheet extends StatefulWidget {
  const QiblaSheet({super.key});

  @override
  State<QiblaSheet> createState() => _QiblaSheetState();
}

class _QiblaSheetState extends State<QiblaSheet>
    with SingleTickerProviderStateMixin {
  double? _qiblaDirection;
  double _compassHeading = 0;
  bool _loading = true;
  String? _error;
  bool _compassAvailable = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initQibla();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initQibla() async {
    final stream = FlutterCompass.events;
    if (stream == null) {
      setState(() {
        _compassAvailable = false;
        _loading = false;
        _error = 'Sensor kompas tidak tersedia di perangkat ini.';
      });
      return;
    }

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final direction = await QiblaService.getQiblaDirection(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      if (direction == null) {
        setState(() {
          _loading = false;
          _error = 'Gagal mengambil data kiblat.\nPeriksa koneksi internet.';
        });
        return;
      }

      setState(() {
        _qiblaDirection = direction;
        _loading = false;
      });

      stream.listen((event) {
        if (mounted && event.heading != null) {
          setState(() {
            _compassHeading = event.heading!;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal mendapatkan lokasi GPS.\nPastikan GPS aktif.';
      });
    }
  }

  double get _qiblaRotation {
    if (_qiblaDirection == null) return 0;
    return (_qiblaDirection! - _compassHeading) * (math.pi / 180);
  }

  double get _compassRotation {
    return -_compassHeading * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.explore,
                  color: AppColors.emeraldGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arah Kiblat',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Menuju Ka\'bah, Makkah Al-Mukarramah',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (_loading)
            _buildLoading()
          else if (_error != null)
            _buildError()
          else
            _buildCompass(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.emeraldGreen, strokeWidth: 2),
            SizedBox(height: 14),
            Text(
              'Menentukan arah kiblat...',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _compassAvailable ? Icons.wifi_off : Icons.sensors_off,
              color: Colors.red.shade300,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_compassAvailable)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _initQibla();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    final qiblaAngleDeg = _qiblaDirection ?? 0;

    return Column(
      children: [
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedRotation(
                turns: _compassRotation / (2 * math.pi),
                duration: const Duration(milliseconds: 100),
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: _CompassRingPainter(),
                ),
              ),

              AnimatedRotation(
                turns: _qiblaRotation / (2 * math.pi),
                duration: const Duration(milliseconds: 100),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: CustomPaint(
                    size: const Size(240, 240),
                    painter: _QiblaArrowPainter(),
                  ),
                ),
              ),

              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore,
                  color: AppColors.emeraldGreen,
                  size: 26,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.emeraldGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.navigation, color: AppColors.emeraldGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                '${qiblaAngleDeg.toStringAsFixed(1)}° dari Utara',
                style: const TextStyle(
                  color: AppColors.emeraldGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Arahkan HP ke jarum hijau untuk menghadap kiblat',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 4, ringPaint);

    final innerPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, innerPaint);

    final tickPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * math.pi / 180;
      final inner = radius - 20;
      final outer = radius - 10;
      canvas.drawLine(
        Offset(center.dx + inner * math.sin(angle),
            center.dy - inner * math.cos(angle)),
        Offset(center.dx + outer * math.sin(angle),
            center.dy - outer * math.cos(angle)),
        tickPaint,
      );
    }

    final directions = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    for (final entry in directions.entries) {
      final angle = entry.value * math.pi / 180;
      final labelRadius = radius - 36;
      final x = center.dx + labelRadius * math.sin(angle);
      final y = center.dy - labelRadius * math.cos(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: entry.key == 'N' ? Colors.red.shade400 : Colors.grey.shade500,
            fontSize: entry.key == 'N' ? 14 : 12,
            fontWeight: entry.key == 'N' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final arrowLength = radius - 50;

    final arrowPaint = Paint()
      ..color = AppColors.emeraldGreen
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy + arrowLength * 0.4),
      Offset(center.dx, center.dy - arrowLength),
      arrowPaint,
    );

    final arrowHead = Path()
      ..moveTo(center.dx, center.dy - arrowLength)
      ..lineTo(center.dx - 8, center.dy - arrowLength + 18)
      ..lineTo(center.dx + 8, center.dy - arrowLength + 18)
      ..close();
    canvas.drawPath(arrowHead, Paint()..color = AppColors.emeraldGreen);

    final tailPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy + arrowLength * 0.4),
      Offset(center.dx, center.dy + arrowLength * 0.5),
      tailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
