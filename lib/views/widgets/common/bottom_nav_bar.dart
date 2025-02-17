import 'package:flutter/material.dart';
// import 'package:remind_me/constants/colors.dart';
import 'package:remind_me/utils/datetime/date_utils.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/theme/app_colors.dart';

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
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      // backgroundColor: AppColors.surface,
      backgroundColor: theme.brightness == Brightness.light 
          ? AppColors.surface
          : theme.colorScheme.surfaceContainer,
      unselectedItemColor: AppColors.iconGrayColor,
      selectedItemColor: Theme.of(context).colorScheme.primary,
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
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.iconGrayColor,
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