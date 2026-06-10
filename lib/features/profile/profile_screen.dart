import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../services/supabase_service.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

// --- TEMA WARNA HEADER ---
const _kEmerald      = Color(0xFF0D5C3A);
const _kEmeraldDeep  = Color(0xFF08402A);
const _kEmeraldMid   = Color(0xFF0F6B43);
const _kGold         = Color(0xFFBF9A3C);
const _kGoldLight    = Color(0xFFE8C96A);

// --- TEMA WARNA DARK MODE ---
const _kDarkBg         = Color(0xFF090D0B); 
const _kDarkCard       = Color(0xFF131B17); 
const _kDarkCardAlt    = Color(0xFF18221D); 
const _kTextWhite      = Color(0xFFF0F4F2); 
const _kTextMuted      = Color(0xFF8A9E93); 

// === STATIC CACHE (MEMORI RAM ANTI-RELOAD) ===
Map<String, dynamic>? _cachedProfileData;
List<dynamic> _cachedLogsData = [];
int? _cachedLastPoints;
int? _cachedLastStreak;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoadingAuth = false;
  final ImagePicker _picker = ImagePicker();
  late ConfettiController _confettiController;
  late AnimationController _headerAnimController;

  StreamSubscription<AuthState>? _authSubscription;
  Timer? _networkTimer; 

  Map<String, dynamic>? _profileData;
  List<dynamic> _allLogsData = [];
  bool _isFetchingData = false;
  bool _isOffline = false; 
  
  bool _isManualLogout = false;

  int? _lastKnownPoints;
  int? _lastKnownStreak; 

  @override
  bool get wantKeepAlive => true; 

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _headerAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _headerAnimController.forward();
    
    _profileData = _cachedProfileData;
    _allLogsData = _cachedLogsData;
    _lastKnownPoints = _cachedLastPoints;
    _lastKnownStreak = _cachedLastStreak;

    _startNetworkMonitor();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _loadDataBackground();
      } else if (event == AuthChangeEvent.signedOut) {
        if (_isManualLogout) {
          _cachedProfileData = null;
          _cachedLogsData = [];
          _cachedLastPoints = null;
          _cachedLastStreak = null;
          if (mounted) {
            setState(() {
              _profileData = null;
              _allLogsData = [];
              _isFetchingData = false;
              _lastKnownPoints = null;
              _lastKnownStreak = null;
            });
          }
          _isManualLogout = false;
        }
      }
    });

    _loadDataBackground();
  }

  @override
  void dispose() {
    _networkTimer?.cancel(); 
    _authSubscription?.cancel(); 
    _confettiController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  void _startNetworkMonitor() {
    _checkInternet(); 
    _networkTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkInternet());
  }

  Future<void> _checkInternet() async {
    bool isCurrentlyOffline = true;
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isCurrentlyOffline = false;
      }
    } catch (_) {
      isCurrentlyOffline = true;
    }

    if (mounted && _isOffline != isCurrentlyOffline) {
      setState(() {
        _isOffline = isCurrentlyOffline;
      });
      if (!isCurrentlyOffline) {
        _loadDataBackground();
      }
    }
  }

  Future<void> _loadDataBackground() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    if (_profileData == null && mounted) {
      setState(() => _isFetchingData = true);
    }

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 3)); 

      final allLogsResponse = await Supabase.instance.client
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .order('log_date', ascending: false)
          .timeout(const Duration(seconds: 3)); 

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_profile_$userId', jsonEncode(profile));
      await prefs.setString('offline_logs_$userId', jsonEncode(allLogsResponse));

      if (!mounted) return;

      int currentPoints = profile['total_points'] ?? 0;
      if (_lastKnownPoints != null) {
        int currentLevel = _getBadgeData(currentPoints)['level'];
        int lastLevel = _getBadgeData(_lastKnownPoints!)['level'];
        if (currentLevel > lastLevel) _triggerLevelUpEffect(currentLevel);
      }
      _lastKnownPoints = currentPoints;
      _cachedLastPoints = currentPoints; 

      int currentStreak = profile['current_streak'] ?? 0;
      if (_lastKnownStreak != null && currentStreak > _lastKnownStreak!) {
        _triggerStreakFireEffect(currentStreak);
      }
      _lastKnownStreak = currentStreak;
      _cachedLastStreak = currentStreak; 

      _cachedProfileData = profile;
      _cachedLogsData = (allLogsResponse as List<dynamic>?) ?? [];

      setState(() {
        _profileData = _cachedProfileData;
        _allLogsData = _cachedLogsData;
        _isFetchingData = false;
      });

    } catch (e) {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final savedProfileStr = prefs.getString('offline_profile_$userId');
        final savedLogsStr = prefs.getString('offline_logs_$userId');

        if (savedProfileStr != null && savedLogsStr != null) {
          final savedProfile = jsonDecode(savedProfileStr);
          final savedLogs = jsonDecode(savedLogsStr);

          _cachedProfileData = savedProfile;
          _cachedLogsData = (savedLogs as List<dynamic>?) ?? [];

          int currentPoints = savedProfile['total_points'] ?? 0;
          _lastKnownPoints = currentPoints;
          _cachedLastPoints = currentPoints;

          int currentStreak = savedProfile['current_streak'] ?? 0;
          _lastKnownStreak = currentStreak;
          _cachedLastStreak = currentStreak;

          setState(() {
            _profileData = _cachedProfileData;
            _allLogsData = _cachedLogsData;
            _isFetchingData = false;
          });
        } else {
          setState(() => _isFetchingData = false);
        }

        if (_profileData != null && mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Koneksi terputus. Menampilkan data tersimpan.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  Map<String, dynamic> _getBadgeData(int points) {
    if (points <= 200) return {'label': 'Musafir Ilmu', 'level': 1, 'image': 'assets/images/badge_1.png', 'color': Colors.blueGrey, 'icon': Icons.menu_book_rounded};
    if (points <= 1000) return {'label': 'Pejuang Shalat', 'level': 2, 'image': 'assets/images/badge_2.png', 'color': const Color(0xFF66BB6A), 'icon': Icons.shield_rounded};
    if (points <= 3000) return {'label': 'Ahli Istiqamah', 'level': 3, 'image': 'assets/images/badge_3.png', 'color': Colors.amber.shade800, 'icon': Icons.auto_awesome_rounded};
    return {'label': 'Penjaga Tiang Agama', 'level': 4, 'image': 'assets/images/badge_4.png', 'color': Colors.deepPurpleAccent.shade100, 'icon': Icons.fort_rounded};
  }

  Color _getStreakColor(int streakDays) {
    if (streakDays < 100) return Colors.amber; 
    if (streakDays < 200) return Colors.deepOrange; 
    if (streakDays < 400) return Colors.purpleAccent.shade400; 
    if (streakDays < 500) return Colors.greenAccent.shade700; 
    return Colors.redAccent.shade700; 
  }

  void _triggerStreakFireEffect(int streakDays) {
    Color streakColor = _getStreakColor(streakDays);
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(context: context, builder: (context) => Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 900), tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, double value, child) => Transform.scale(scale: value,
            child: Opacity(opacity: value.clamp(0.0, 1.0),
              child: AlertDialog(backgroundColor: Colors.transparent, elevation: 0,
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Stack(alignment: Alignment.center, children: [
                    Icon(Icons.local_fire_department_rounded, size: 160, color: streakColor.withOpacity(0.4)),
                    Icon(Icons.local_fire_department_rounded, size: 130, color: streakColor),
                    Positioned(bottom: 10, child: Text("$streakDays", style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0,4))]))),
                  ]),
                  const SizedBox(height: 16),
                  const Text("STREAK SHALAT!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 12)])),
                  Text("$streakDays Hari Berturut-turut", style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)])),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: streakColor, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 5),
                    child: const Text('Pertahankan!', style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ),
            ),
          ),
        ),
      ));
    });
  }

  void _showFullImage(String? avatarUrl, String fullName, Map<String, dynamic> badge) {
    showDialog(context: context, builder: (context) => Dialog(backgroundColor: Colors.transparent, elevation: 0,
      child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        clipBehavior: Clip.antiAlias, 
        child: avatarUrl != null 
            ? Image.network(
                avatarUrl, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text(fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: badge['color'])));
                },
              )
            : Center(child: Text(fullName.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: badge['color']))))));
  }

  void _showBadgeInfo() {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _kDarkCard,
      title: const Text('Tingkat Perjalanan', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildBadgeInfoRow('assets/images/badge_1.png', 'Musafir Ilmu', '0 - 200 Poin', Colors.blueGrey),
        const Divider(color: _kDarkCardAlt),
        _buildBadgeInfoRow('assets/images/badge_2.png', 'Pejuang Shalat', '201 - 1000 Poin', const Color(0xFF66BB6A)),
        const Divider(color: _kDarkCardAlt),
        _buildBadgeInfoRow('assets/images/badge_3.png', 'Ahli Istiqamah', '1001 - 3000 Poin', Colors.amber.shade600),
        const Divider(color: _kDarkCardAlt),
        _buildBadgeInfoRow('assets/images/badge_4.png', 'Penjaga Tiang Agama', '3000+ Poin', Colors.deepPurpleAccent.shade100),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Tutup', style: TextStyle(color: _kGoldLight)))],
    ));
  }

  Widget _buildBadgeInfoRow(String imagePath, String title, String points, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Image.asset(imagePath, width: 50, height: 50, errorBuilder: (c, e, s) => Icon(Icons.shield, color: color, size: 40)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          Text(points, style: const TextStyle(color: _kTextMuted, fontSize: 12)),
        ])),
      ]));
  }

  void _triggerLevelUpEffect(int newLevel) {
    _confettiController.play();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false, builder: (context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false, colors: const [Colors.green, Colors.blue, Colors.amber, Colors.purple, Colors.white]),
          TweenAnimationBuilder(duration: const Duration(milliseconds: 800), tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.elasticOut,
            builder: (context, double value, child) => Transform.scale(scale: value,
              child: Opacity(opacity: value.clamp(0.0, 1.0),
                child: AlertDialog(backgroundColor: Colors.transparent, elevation: 0,
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text("MASHALLAH!", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10)])),
                    const SizedBox(height: 8),
                    const Text("Pangkat Anda Telah Naik!", style: TextStyle(color: Colors.white, fontSize: 18,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10)])),
                    const SizedBox(height: 30),
                    Image.asset('assets/images/badge_$newLevel.png', width: 200,
                        errorBuilder: (c, e, s) => const Icon(Icons.star, color: Colors.amber, size: 100)),
                    const SizedBox(height: 30),
                    ElevatedButton(onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.emeraldGreen),
                      child: const Text('Lanjutkan')),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ));
    });
  }

  String? _extractFileNameFromUrl(String url) {
    try { return url.split('/public/avatars/').last; } catch (e) { return null; }
  }

  void _showLogoutConfirmation() {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: _kDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      content: const Text('Apakah Anda yakin ingin keluar dari akun ini?', style: TextStyle(color: _kTextMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: () async { 
            Navigator.pop(context); 
            _isManualLogout = true; 
            
            final userId = Supabase.instance.client.auth.currentUser?.id;
            if (userId != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('offline_profile_$userId');
              await prefs.remove('offline_logs_$userId');
            }
            
            await _supabaseService.signOut(); 
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Keluar')),
      ],
    ));
  }

  Future<void> _showEditProfile(String userId, String currentName, String? currentAvatarUrl) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    File? selectedImage;
    bool isSaving = false;
    bool removePhoto = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          return Container(
            decoration: const BoxDecoration(
              color: _kDarkCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: bottomInset + bottomPadding + 16, 
              left: 24, right: 24, top: 16,
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              CircleAvatar(radius: 45, backgroundColor: _kDarkCardAlt,
                backgroundImage: selectedImage != null ? FileImage(selectedImage!)
                    : (!removePhoto && currentAvatarUrl != null ? NetworkImage(currentAvatarUrl) : null) as ImageProvider?,
                child: (selectedImage == null && (removePhoto || currentAvatarUrl == null))
                    ? const Icon(Icons.person, size: 45, color: Colors.grey) : null),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton.icon(
                  onPressed: () async {
                    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) {
                      final croppedFile = await ImageCropper().cropImage(sourcePath: picked.path,
                        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                        uiSettings: [
                          AndroidUiSettings(toolbarTitle: 'Potong Foto', toolbarColor: _kEmeraldDeep,
                              toolbarWidgetColor: Colors.white, lockAspectRatio: true, cropStyle: CropStyle.circle),
                          IOSUiSettings(title: 'Potong Foto', aspectRatioLockEnabled: true, cropStyle: CropStyle.circle),
                        ]);
                      if (croppedFile != null) setModalState(() { selectedImage = File(croppedFile.path); removePhoto = false; });
                    }
                  },
                  icon: const Icon(Icons.camera_alt, size: 16, color: _kGoldLight),
                  label: const Text('Ganti Foto', style: TextStyle(color: _kGoldLight))),
                if (selectedImage != null || (!removePhoto && currentAvatarUrl != null))
                  TextButton.icon(
                    onPressed: () { setModalState(() { selectedImage = null; removePhoto = true; }); },
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    label: const Text('Hapus', style: TextStyle(color: Colors.redAccent))),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Panggilan',
                  labelStyle: const TextStyle(color: _kTextMuted),
                  hintText: 'Masukkan nama Anda...',
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  filled: true,
                  fillColor: _kDarkBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kGoldLight, width: 1.5)))),
              const SizedBox(height: 24), 
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.trim().isEmpty) return;
                    setModalState(() => isSaving = true);
                    try {
                      String? newAvatarUrl = currentAvatarUrl;
                      if (removePhoto) {
                        if (currentAvatarUrl != null) {
                          final oldFileName = _extractFileNameFromUrl(currentAvatarUrl);
                          if (oldFileName != null) await Supabase.instance.client.storage.from('avatars').remove([oldFileName]);
                        }
                        newAvatarUrl = null;
                      } else if (selectedImage != null) {
                        if (currentAvatarUrl != null) {
                          final oldFileName = _extractFileNameFromUrl(currentAvatarUrl);
                          if (oldFileName != null) await Supabase.instance.client.storage.from('avatars').remove([oldFileName]);
                        }
                        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
                        await Supabase.instance.client.storage.from('avatars')
                            .upload(fileName, selectedImage!, fileOptions: const FileOptions(upsert: true));
                        newAvatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
                      }
                      await Supabase.instance.client.from('profiles').update(
                          {'full_name': nameController.text.trim(), 'avatar_url': newAvatarUrl}).eq('id', userId);
                      
                      _loadDataBackground();

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).clearSnackBars(); // Hapus antrean pesan lama
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Profil berhasil diperbarui!'), backgroundColor: _kEmerald));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red));
                      }
                    } finally {
                      setModalState(() => isSaving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _kEmerald, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
            ]),
          );
        },
      ),
    );
  }

  // --- REVISI: Fungsi Handle Google Sign-in Lebih Cerdas & Responsif ---
  Future<void> _handleGoogleSignIn() async {
    // Segera hapus Snackbar yang lama agar tidak antre (Responsif)
    ScaffoldMessenger.of(context).clearSnackBars();

    // Pencegahan awal: Jika sensor membaca offline, tolak permintaan login langsung
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada koneksi internet. Silakan periksa jaringan Anda.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoadingAuth = true);
    try {
      await _supabaseService.signInWithGoogle();
    } catch (error) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat masuk.';
        final errorStr = error.toString().toLowerCase();
        
        // Filter cerdas: Walaupun Google bilang 'canceled', kalau HP Offline, ubah jadi peringatan jaringan
        if (_isOffline || errorStr.contains('socket') || errorStr.contains('timeout') || errorStr.contains('network') || errorStr.contains('failed host lookup') || errorStr.contains('7')) {
          errorMessage = 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
        } else if (errorStr.contains('cancel') || errorStr.contains('batal')) {
          errorMessage = 'Proses masuk dibatalkan.';
        } else {
          errorMessage = 'Gagal terhubung ke server. Silakan coba lagi nanti.';
        }
        
        ScaffoldMessenger.of(context).clearSnackBars(); // Hapus lagi memastikan tidak numpuk
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: Colors.red.shade800, 
            behavior: SnackBarBehavior.floating
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        if (session != null) return _buildDashboard();
        return _buildLoginView();
      },
    );
  }

  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: _kEmerald,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GeometricBg(opacity: 0.10))),
        SafeArea(child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.person_outline_rounded, size: 52, color: _kGoldLight),
            const SizedBox(height: 24),
            // REVISI: Garis kuning dihapus dari bawah teks
            const Text('PROFIL IBADAH', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3.5)),
            const SizedBox(height: 20),
            Text('Masuk untuk mencatat progres harian\ndan membangun kebiasaan shalat.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.65), height: 1.7)),
            const SizedBox(height: 48),
            _isLoadingAuth ? const CircularProgressIndicator(color: _kGoldLight)
                : SizedBox(
                    width: double.infinity, 
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: Colors.white, // Background tombol putih
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // REVISI: Menampilkan gambar Logo Google jika ada.
                          Image.asset(
                            'assets/images/google_logo.png', 
                            height: 24, 
                            width: 24, 
                            errorBuilder: (context, _, __) {
                              return Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 18, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text('Lanjutkan dengan ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                          
                          // REVISI: Format Teks Google sesuai warnanya
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              children: [
                                TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))), 
                                TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))), 
                                TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))), 
                                TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))), 
                                TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))), 
                                TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))), 
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
          ])))),
      ]),
    );
  }

  Widget _buildDashboard() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return const Center(child: Text('Terjadi kesalahan data.'));

    if (_profileData == null && _isFetchingData) {
      return const Scaffold(backgroundColor: _kDarkBg, body: Center(child: CircularProgressIndicator(color: _kEmerald)));
    }

    final profileData = _profileData ?? {
      'full_name': 'Menunggu Koneksi...',
      'avatar_url': null,
      'total_points': 0,
      'current_streak': 0,
      'longest_streak': 0,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    final allLogsData = _allLogsData;
    final recentLogsData = allLogsData.take(7).toList();
    final fullName = profileData['full_name'] ?? 'Menunggu Koneksi...';
    final avatarUrl = profileData['avatar_url'];
    final totalPoints = profileData['total_points'] ?? 0;
    final currentStreak = profileData['current_streak'] ?? 0;
    final longestStreak = profileData['longest_streak'] ?? 0;
    final badge = _getBadgeData(totalPoints);

    WidgetsBinding.instance.addPostFrameCallback((_) { ScaffoldMessenger.of(context).clearSnackBars(); });

    int countTepat = 0, countJamak = 0, countQadha = 0;
    for (var log in allLogsData) {
      final prayers = [log['subuh'], log['dzuhur'], log['asar'], log['maghrib'], log['isya']];
      for (var p in prayers) {
        if (p == 'TEPAT_WAKTU') countTepat++;
        else if (p == 'JAMAK') countJamak++;
        else if (p == 'QADHA') countQadha++;
      }
    }

    int countKosong = 0;
    final createdAtStr = profileData['created_at'];
    if (createdAtStr != null) {
      final createdAt = DateTime.parse(createdAtStr).toLocal();
      final start = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int pastDays = today.difference(start).inDays;
      if (pastDays < 0) pastDays = 0;
      final totalExpectedPastPrayers = pastDays * 5;
      int completedPastPrayers = 0;
      for (var log in allLogsData) {
        final logDate = DateTime.parse(log['log_date']);
        if (logDate.isBefore(today)) {
          final prayers = [log['subuh'], log['dzuhur'], log['asar'], log['maghrib'], log['isya']];
          for (var p in prayers) { if (p == 'TEPAT_WAKTU' || p == 'JAMAK' || p == 'QADHA') completedPastPrayers++; }
        }
      }
      countKosong = totalExpectedPastPrayers - completedPastPrayers;
      if (countKosong < 0) countKosong = 0;
    }

    return Scaffold(
      backgroundColor: _kDarkBg, 
      body: RefreshIndicator(
        color: _kEmerald,
        onRefresh: _loadDataBackground, 
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _kEmeraldDeep,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            expandedHeight: 0,
            titleSpacing: 24,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_ruangshalat.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text('PROFIL SAYA',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.8)),
              ],
            ),
            centerTitle: false,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                color: _kDarkCardAlt, elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'edit') _showEditProfile(userId, fullName, avatarUrl);
                  else if (value == 'logout') _showLogoutConfirmation();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.white), SizedBox(width: 12),
                    Text('Edit Profil', style: TextStyle(fontSize: 14, color: Colors.white))])),
                  const PopupMenuItem(value: 'logout', child: Row(children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent), SizedBox(width: 12),
                    Text('Keluar', style: TextStyle(fontSize: 14, color: Colors.redAccent))])),
                ]),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: _isOffline ? 36.0 : 0.0,
              color: Colors.redAccent.shade700,
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Container(
                    height: 36.0,
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 8),
                        Text('Koneksi terputus. Anda sedang offline.', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: _ProfileHero(
            fullName: fullName, 
            avatarUrl: avatarUrl, 
            badge: badge,
            isOffline: _isOffline, 
            onTapAvatar: () => _showFullImage(avatarUrl, fullName, badge),
            onTapBadge: _showBadgeInfo,
          )),

          SliverToBoxAdapter(
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _BodyPatternPainter())),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  const _SectionTitle(text: 'STATISTIK IBADAH', icon: Icons.bar_chart_rounded),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _StatCard(
                        title: 'Streak Kini',
                        value: '$currentStreak',
                        unit: 'Hari Beruntun',
                        icon: Icons.local_fire_department_rounded,
                        color: _getStreakColor(currentStreak))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        title: 'Total Poin',
                        value: '$totalPoints',
                        unit: 'Poin Terkumpul',
                        icon: Icons.stars_rounded,
                        color: _kGold)),
                  ]),
                  const SizedBox(height: 12),
                  _StatCardWide(
                      title: 'Rekor Streak Terlama',
                      value: '$longestStreak',
                      unit: 'Hari  ·  Alhamdulillah, pertahankan!',
                      icon: Icons.emoji_events_rounded,
                      color: _kEmerald),

                  const SizedBox(height: 28),

                  const _SectionTitle(text: 'AKUMULASI SEPANJANG WAKTU', icon: Icons.history_rounded),
                  const SizedBox(height: 14),
                  _AccumulationRow(
                      countTepat: countTepat,
                      countJamak: countJamak,
                      countQadha: countQadha,
                      countKosong: countKosong),

                  const SizedBox(height: 28),

                  const _SectionTitle(text: 'RIWAYAT 7 HARI TERAKHIR', icon: Icons.calendar_month_rounded),
                  const SizedBox(height: 14),

                  if (recentLogsData.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kDarkCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(children: [
                        Icon(Icons.mosque_rounded, size: 36, color: _kEmerald.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        const Text('Belum ada riwayat shalat.',
                            style: TextStyle(color: _kTextMuted, fontSize: 14)),
                      ]),
                    )
                  else
                    _PrayerHistoryTable(logs: recentLogsData),

                  const SizedBox(height: 16),
                  const _LegendRow(),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REDESIGN WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionTitle({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: _kGoldLight), 
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _kTextWhite, 
            letterSpacing: 1.2,
          )),
    ]);
  }
}

class _ProfileHero extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;
  final Map<String, dynamic> badge;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapBadge;
  final bool isOffline; 

  const _ProfileHero({
    required this.fullName, 
    required this.avatarUrl, 
    required this.badge,
    required this.onTapAvatar, 
    required this.onTapBadge,
    required this.isOffline, 
  });

  @override
  Widget build(BuildContext context) {
    final int level = badge['level'] as int;
    final Offset photoNudge = switch (level) {
      1 => const Offset(0, -5),
      2 => const Offset(0, 0),
      3 => const Offset(-3, 0),
      4 => const Offset(0, 0),
      _ => Offset.zero,
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A4028), Color(0xFF0D5C3A), Color(0xFF0F5438)]),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GeometricBg(opacity: 0.11))),
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(height: 1.5, decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, _kGold, _kGoldLight, _kGold, Colors.transparent])))),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            GestureDetector(
              onTap: onTapAvatar,
              child: SizedBox(width: 120, height: 120,
                child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                  Transform.translate(
                    offset: photoNudge,
                    child: Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.85), width: 2.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 5))]),
                      child: ClipOval(
                        child: avatarUrl != null
                          ? Image.network(
                              avatarUrl!, 
                              key: ValueKey('$avatarUrl-$isOffline'), 
                              fit: BoxFit.cover, 
                              width: 76, 
                              height: 76,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: (badge['color'] as Color).withOpacity(0.18),
                                  child: Center(
                                    child: Text(
                                      fullName.substring(0, 1).toUpperCase(),
                                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: badge['color'])
                                    )
                                  )
                                );
                              },
                            )
                          : Container(color: (badge['color'] as Color).withOpacity(0.18),
                              child: Center(child: Text(fullName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: badge['color']))))),
                    ),
                  ),
                  IgnorePointer(child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Image.asset(badge['image'], key: ValueKey(badge['level']),
                      width: 120, height: 120,
                      fit: BoxFit.fill,
                      errorBuilder: (ctx, err, st) => Container(width: 120, height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: badge['color'], width: 3)))),
                  )),
                ])),
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                  letterSpacing: 0.2, shadows: [Shadow(color: Colors.black26, blurRadius: 6)])),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onTapBadge,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(badge['icon'] as IconData, size: 13, color: _kGoldLight),
                  const SizedBox(width: 6),
                  Text(badge['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: _kGoldLight, letterSpacing: 0.3)),
                  const SizedBox(width: 5),
                  Icon(Icons.info_outline_rounded, size: 11, color: _kGoldLight.withOpacity(0.65)),
                ]),
              ),
            ])),
          ]),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _kDarkCard, 
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kTextMuted, letterSpacing: 0.3)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28), 
            const SizedBox(width: 8),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, height: 1.1)),
          ]
        ),
        const SizedBox(height: 6),
        Text(unit, style: const TextStyle(fontSize: 10, color: _kTextMuted)),
      ]),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  const _StatCardWide({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kDarkCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kTextMuted, letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(unit, style: const TextStyle(fontSize: 10, color: _kTextMuted)),
        ])),
      ]),
    );
  }
}

class _AccumulationRow extends StatelessWidget {
  final int countTepat, countJamak, countQadha, countKosong;
  const _AccumulationRow({required this.countTepat, required this.countJamak,
      required this.countQadha, required this.countKosong});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tepat', countTepat, const Color(0xFF66BB6A), Icons.check_circle_rounded),
      ('Jamak', countJamak, Colors.blue.shade400, Icons.compress_rounded),
      ('Qadha', countQadha, AppColors.gold, Icons.update_rounded),
      ('Kosong', countKosong, Colors.grey.shade600, Icons.radio_button_unchecked_rounded),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4), 
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _kDarkCard, 
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Column(children: [
              Icon(item.$4, color: item.$3, size: 22),
              const SizedBox(height: 10),
              Text('${item.$2}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: item.$3)),
              const SizedBox(height: 4),
              Text(item.$1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _kTextMuted, letterSpacing: 0.4)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _PrayerHistoryTable extends StatelessWidget {
  final List<dynamic> logs;
  const _PrayerHistoryTable({required this.logs});

  String _fmt(String dateStr) {
    try { final date = DateTime.parse(dateStr);
      const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      return '${date.day} ${m[date.month - 1]}'; } catch (_) { return dateStr; }
  }

  Widget _dot(String? status) {
    Color fill = Colors.transparent; 
    Color border = Colors.grey.shade700; 
    if (status == 'TEPAT_WAKTU') { fill = const Color(0xFF66BB6A); border = const Color(0xFF66BB6A); }
    else if (status == 'JAMAK') { fill = Colors.blue.shade400; border = Colors.blue.shade400; }
    else if (status == 'QADHA') { fill = AppColors.gold; border = AppColors.gold; }
    return Expanded(flex: 1, child: Center(child: Container(width: 13, height: 13,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle, border: Border.all(color: border, width: 1.8),
            boxShadow: fill != Colors.transparent ? [BoxShadow(color: fill.withOpacity(0.35), blurRadius: 4, spreadRadius: 0.5)] : null))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias, 
      child: Column(children: [
        Container(
          color: _kDarkCard, 
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _kTextMuted, letterSpacing: 1.0))),
            ...['S','D','A','M','I'].map((l) => Expanded(flex: 1, child: Center(
                child: Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _kGoldLight, letterSpacing: 0.5))))),
          ]),
        ),
        ...logs.asMap().entries.map((entry) {
          final log = entry.value; 
          final isEven = entry.key.isEven;
          return Container(
            color: isEven ? _kDarkCardAlt : _kDarkCard, 
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Expanded(flex: 2, child: Text(_fmt(log['log_date']),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kTextWhite))), 
                _dot(log['subuh']), _dot(log['dzuhur']), _dot(log['asar']), _dot(log['maghrib']), _dot(log['isya']),
              ])),
          );
        }),
      ]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (const Color(0xFF66BB6A), 'Tepat Waktu', false),
      (Colors.blue.shade400, 'Jamak', false),
      (AppColors.gold, 'Qadha', false),
      (Colors.grey.shade600, 'Kosong', true),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kDarkCard, 
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16, runSpacing: 8,
        children: items.map((item) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 9, height: 9,
              decoration: BoxDecoration(
                color: item.$3 ? Colors.transparent : item.$1,
                shape: BoxShape.circle,
                border: Border.all(color: item.$1, width: 2),
              )),
          const SizedBox(width: 5),
          Text(item.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextMuted)),
        ])).toList(),
      ),
    );
  }
}

class _GeometricBg extends CustomPainter {
  final double opacity;
  const _GeometricBg({this.opacity = 0.10});

  void _drawStar8(Canvas canvas, Offset center, double r, Paint paint) {
    const n = 8;
    final innerR = r * 0.42;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final angle = (i * math.pi / n) - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    final prev = paint.color;
    paint.color = prev.withOpacity(prev.opacity * 0.35);
    canvas.drawCircle(center, r * 1.18, paint);
    paint.color = prev;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()..color = Colors.white.withOpacity(opacity)..strokeWidth = 0.7..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = _kGold.withOpacity(opacity * 0.45)..style = PaintingStyle.fill;
    const tileSize = 50.0;
    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / tileSize).ceil() + 2;
    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize * 0.866;
        _drawStar8(canvas, Offset(cx, cy), tileSize * 0.36, strokePaint);
        canvas.drawCircle(Offset(cx, cy), 1.4, dotPaint);
      }
    }
  }

  @override bool shouldRepaint(covariant CustomPainter _) => false;
}

class _BodyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015) 
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    const tileSize = 64.0;
    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / tileSize).ceil() + 2;
    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize * 0.866;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * math.pi / 3) - math.pi / 6;
          final x = cx + tileSize * 0.38 * math.cos(angle);
          final y = cy + tileSize * 0.38 * math.sin(angle);
          if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}