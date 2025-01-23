import 'package:flutter/material.dart';
import 'package:remind_me/constants/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '日期',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer),
          label: '时间',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }
}