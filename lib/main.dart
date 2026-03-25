import 'package:flutter/material.dart';

import 'package:ruang_shalat/core/theme/app_theme.dart';
import 'package:ruang_shalat/features/guide/guide_screen.dart';
import 'package:ruang_shalat/features/home/home_screen.dart';
import 'package:ruang_shalat/shared/widgets/main_bottom_nav_bar.dart';

void main() {
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman (Nanti diganti dengan file UI dari folder features/)
  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    GuideScreen(),
    Center(child: Text('Halaman Kiblat', style: TextStyle(fontSize: 24))),
    Center(child: Text('Halaman Lainnya', style: TextStyle(fontSize: 24))),
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
