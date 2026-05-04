import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';
import 'package:ruang_shalat/services/qibla_service.dart';

class QiblaArScreen extends StatefulWidget {
  const QiblaArScreen({super.key});

  @override
  State<QiblaArScreen> createState() => _QiblaArScreenState();
}

class _QiblaArScreenState extends State<QiblaArScreen>
    with SingleTickerProviderStateMixin {
  // ── Kamera ────────────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _cameraPermissionDenied = false;

  // ── Kiblat & Kompas ───────────────────────────────────────────────────────
  double? _qiblaDirection;
  double _compassHeading = 0;
  StreamSubscription<CompassEvent>? _compassSub;
  bool _compassAvailable = true;

  // ── Status ────────────────────────────────────────────────────────────────
  bool _loading = true;
  String? _error;

  // ── Animasi aligned ───────────────────────────────────────────────────────
  late AnimationController _alignedAnim;
  late Animation<double> _alignedOpacity;

  @override
  void initState() {
    super.initState();
    // Lock orientasi ke portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _alignedAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _alignedOpacity = CurvedAnimation(
      parent: _alignedAnim,
      curve: Curves.easeInOut,
    );

    _initAll();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _cameraController?.dispose();
    _compassSub?.cancel();
    _alignedAnim.dispose();
    super.dispose();
  }

  Future<void> _initAll() async {
    await Future.wait([
      _initCamera(),
      _initQibla(),
    ]);
  }

  // ── Init Kamera ──────────────────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Pilih kamera belakang
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _cameraReady = true;
      });
    } catch (e) {
      if (e is CameraException && e.code == 'CameraAccessDenied') {
        setState(() => _cameraPermissionDenied = true);
      }
      // Kamera gagal tapi kompas tetap bisa jalan
    }
  }

  // ── Init Qibla & Kompas ──────────────────────────────────────────────────
  Future<void> _initQibla() async {
    // Cek sensor kompas
    if (FlutterCompass.events == null) {
      setState(() {
        _compassAvailable = false;
        _loading = false;
        _error = 'Sensor kompas tidak tersedia\ndi perangkat ini.';
      });
      return;
    }

    try {
      // Ambil posisi GPS
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Fetch sudut kiblat dari Aladhan API
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

      // Subscribe stream kompas
      _compassSub = FlutterCompass.events!.listen((event) {
        if (!mounted || event.heading == null) return;
        final newHeading = event.heading!;
        setState(() => _compassHeading = newHeading);

        // Cek apakah sudah tepat menghadap kiblat (±5°)
        if (_qiblaDirection != null) {
          double diff = (_qiblaDirection! - newHeading).abs() % 360;
          if (diff > 180) diff = 360 - diff;
          if (diff <= 5.0) {
            _alignedAnim.forward();
          } else {
            _alignedAnim.reverse();
          }
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

  // ── Kalkulasi rotasi ─────────────────────────────────────────────────────

  /// Rotasi ring kompas — ikut orientasi HP (utara selalu "atas sebenarnya")
  double get _ringRotation => -_compassHeading * (math.pi / 180);

  /// Rotasi jarum kiblat relatif terhadap orientasi HP
  double get _needleRotation =>
      ((_qiblaDirection ?? 0) - _compassHeading) * (math.pi / 180);

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // [1] Background: kamera atau hitam
          _buildCameraBackground(),

          // [2] Gradient gelap atas & bawah
          _buildGradientOverlay(),

          // [3] Konten utama (kompas + info)
          SafeArea(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildCameraBackground() {
    if (_cameraReady && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }
    return Container(color: Colors.black87);
  }

  Widget _buildGradientOverlay() {
    return Column(
      children: [
        // Gradient atas
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
        const Spacer(),
        // Gradient bawah
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // ── AppBar transparan ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Arah Kiblat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 48), // spacer biar judul center
            ],
          ),
        ),

        const Spacer(),

        // ── Kompas / Loading / Error ─────────────────────────────────────
        if (_loading)
          _buildLoadingOverlay()
        else if (_error != null)
          _buildErrorOverlay()
        else
          _buildCompassOverlay(),

        const Spacer(),

        // ── Info bawah ───────────────────────────────────────────────────
        if (!_loading && _error == null) _buildBottomInfo(),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoadingOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.emeraldGreen,
          strokeWidth: 2.5,
        ),
        const SizedBox(height: 16),
        Text(
          'Menentukan arah kiblat...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────
  Widget _buildErrorOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _compassAvailable ? Icons.wifi_off : Icons.sensors_off,
            color: Colors.red.shade300,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade300, fontSize: 14),
          ),
          if (_compassAvailable) ...[
            const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  // ── Kompas AR ────────────────────────────────────────────────────────────
  Widget _buildCompassOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge "Menghadap Kiblat"
        FadeTransition(
          opacity: _alignedOpacity,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Menghadap Kiblat!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Ring kompas + jarum
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring kompas (berputar ikut orientasi HP)
              AnimatedRotation(
                turns: _ringRotation / (2 * math.pi),
                duration: const Duration(milliseconds: 80),
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: _ArCompassRingPainter(),
                ),
              ),

              // Jarum kiblat (selalu menunjuk ke Ka'bah)
              AnimatedRotation(
                turns: _needleRotation / (2 * math.pi),
                duration: const Duration(milliseconds: 80),
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: _ArNeedlePainter(),
                ),
              ),

              // Titik tengah
              _buildCenterDot(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCenterDot() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(Icons.explore, color: Colors.white, size: 28),
    );
  }

  Widget _buildBottomInfo() {
    final deg = _qiblaDirection?.toStringAsFixed(1) ?? '--';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Derajat kiblat
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.navigation,
                  color: AppColors.emeraldGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                '$deg° dari Utara',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Putar badan hingga jarum hijau lurus ke atas',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 12,
          ),
        ),
        if (_cameraPermissionDenied) ...[
          const SizedBox(height: 8),
          Text(
            '⚠️ Izin kamera ditolak — kompas tetap berjalan',
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Custom Painters ────────────────────────────────────────────────────────────

/// Ring kompas AR — transparan dengan garis & label N/S/E/W
class _ArCompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Lingkaran utama
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Tick marks setiap 10°
    for (int i = 0; i < 36; i++) {
      final angle = i * 10 * math.pi / 180;
      final isMajor = i % 9 == 0; // setiap 90° (N/E/S/W)
      final tickLen = isMajor ? 14.0 : 7.0;
      final outerR = radius - 6;
      final innerR = outerR - tickLen;

      canvas.drawLine(
        Offset(center.dx + outerR * math.sin(angle),
            center.dy - outerR * math.cos(angle)),
        Offset(center.dx + innerR * math.sin(angle),
            center.dy - innerR * math.cos(angle)),
        Paint()
          ..color = isMajor
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = isMajor ? 2.0 : 1.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Label N / E / S / W
    final labels = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    for (final entry in labels.entries) {
      final angle = entry.value * math.pi / 180;
      final labelR = radius - 32;
      final x = center.dx + labelR * math.sin(angle);
      final y = center.dy - labelR * math.cos(angle);

      final isNorth = entry.key == 'N';
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: isNorth ? Colors.red.shade400 : Colors.white,
            fontSize: isNorth ? 15 : 13,
            fontWeight: isNorth ? FontWeight.bold : FontWeight.w500,
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

/// Jarum kiblat AR — panah hijau yang menunjuk ke Ka'bah
class _ArNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final needleLen = radius - 52;

    // Shadow/glow
    final glowPaint = Paint()
      ..color = AppColors.emeraldGreen.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(
      Offset(center.dx, center.dy + needleLen * 0.3),
      Offset(center.dx, center.dy - needleLen),
      glowPaint,
    );

    // Batang jarum utama
    canvas.drawLine(
      Offset(center.dx, center.dy + needleLen * 0.3),
      Offset(center.dx, center.dy - needleLen),
      Paint()
        ..color = AppColors.emeraldGreen
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Kepala panah (segitiga)
    final arrowHead = Path()
      ..moveTo(center.dx, center.dy - needleLen)
      ..lineTo(center.dx - 10, center.dy - needleLen + 22)
      ..lineTo(center.dx + 10, center.dy - needleLen + 22)
      ..close();
    canvas.drawPath(arrowHead, Paint()..color = AppColors.emeraldGreen);

    // Ekor (abu-abu transparan)
    canvas.drawLine(
      Offset(center.dx, center.dy + needleLen * 0.3),
      Offset(center.dx, center.dy + needleLen * 0.45),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
