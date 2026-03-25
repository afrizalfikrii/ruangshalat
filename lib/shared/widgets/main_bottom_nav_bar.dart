import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.mosque),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Panduan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Kiblat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'Lainnya',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: AppColors.emeraldGreen,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
    );
  }
}
