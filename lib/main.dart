import 'package:flutter/material.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E6351)), // Emerald Green
        useMaterial3: true,
      ),
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
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Halaman Beranda', style: TextStyle(fontSize: 24))),
    Center(child: Text('Halaman Panduan', style: TextStyle(fontSize: 24))),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar 4 item tetap terlihat rapi
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Panduan'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Kiblat'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Lainnya'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E6351), // Emerald Green
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}