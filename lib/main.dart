import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:ruang_shalat/features/profile/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ruang_shalat/core/constants/supabase_constants.dart';
import 'package:ruang_shalat/core/theme/app_theme.dart';
import 'package:ruang_shalat/features/guide/guide_screen.dart';
import 'package:ruang_shalat/features/home/home_screen.dart';
import 'package:ruang_shalat/features/quran/quran_screen.dart';
import 'package:ruang_shalat/services/notification_service.dart';
import 'package:ruang_shalat/shared/widgets/main_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi notifikasi
  await NotificationService().init();
  
  // Load konfigurasi .env sebelum menginisialisasi layanan lain
  await dotenv.load(fileName: ".env");
  
  // Menambahkan inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const RuangShalatApp());
}

class RuangShalatApp extends StatelessWidget {
  const RuangShalatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruang Shalat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const NoOverscrollBehavior(),
      home: const MainScreen(),
    );
  }
}

class NoOverscrollBehavior extends ScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang aktif
  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    GuideScreen(),
    QuranScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}