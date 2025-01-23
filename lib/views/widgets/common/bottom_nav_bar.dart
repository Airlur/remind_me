import 'package:flutter/material.dart';
import 'package:remind_me/constants/colors.dart';
import 'package:remind_me/utils/datetime/date_utils.dart';
import 'package:remind_me/l10n/l10n.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

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
      items: [
        BottomNavigationBarItem(
          icon: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.calendar_today),
              Positioned(
                top: 7,
                child: Text(
                  DateTimeUtils.getCurrentDayString(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: currentIndex == 0 
                      ? AppColors.primary 
                      : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor 
                          ?? Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          label: context.l10n.date,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time),
          label: context.l10n.time,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: context.l10n.settings,
        ),
      ],
    );
  }
}