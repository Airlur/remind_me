import 'package:flutter/material.dart';

/// 事件项的图标映射
class EventIconMapping {
  static const Map<String, IconData> icons = {
    'favorite': Icons.favorite,
    'star': Icons.star,
    'cake': Icons.cake,
    'celebration': Icons.celebration,
    'emoji_events': Icons.emoji_events,
    'emoji_emotions': Icons.emoji_emotions,
    'local_activity': Icons.local_activity,
    'park': Icons.park,
    'beach_access': Icons.beach_access,
    'directions_bike': Icons.directions_bike,
    'directions_run': Icons.directions_run,
    'sports_basketball': Icons.sports_basketball,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'spa': Icons.spa,
    'flight': Icons.flight,
    'directions_car': Icons.directions_car,
    'music_note': Icons.music_note,
    'sports_esports': Icons.sports_esports,
    'sports_soccer': Icons.sports_soccer,
    'sports_tennis': Icons.sports_tennis,
    'sports_volleyball': Icons.sports_volleyball,
    'sports_football': Icons.sports_football,
    'nightlife': Icons.nightlife,
    'wb_sunny': Icons.wb_sunny,
    'ac_unit': Icons.ac_unit,
    'people': Icons.people,
    'volunteer_activism': Icons.volunteer_activism,
    'menu_book': Icons.menu_book,
    'computer': Icons.computer,
    'lightbulb': Icons.lightbulb,
  };

  static IconData getIcon(String name) {
    return icons[name] ?? Icons.error;
  }

  static String? getIconName(IconData icon) {
    return icons.entries
        .firstWhere((entry) => entry.value == icon,
            orElse: () => const MapEntry('error', Icons.error))
        .key;
  }
}

/// 分类的图标映射
class CategoryIconMapping {
  static const Map<String, IconData> icons = {
    'home': Icons.home_outlined,
    'work': Icons.work_outline,
    'school': Icons.school_outlined,
    'favorite': Icons.favorite_outline,
    'shopping': Icons.shopping_cart_outlined,
    'game': Icons.sports_esports_outlined,
    'restaurant': Icons.restaurant_outlined,
    'hospital': Icons.local_hospital_outlined,
    'flight': Icons.flight_outlined,
    'fitness': Icons.fitness_center_outlined,
    'pets': Icons.pets_outlined,
    'family': Icons.family_restroom_outlined,
  };

  static IconData getIcon(String name) {
    return icons[name] ?? Icons.folder_outlined;
  }

  static String getIconName(IconData icon) {
    return icons.entries
        .firstWhere((entry) => entry.value == icon,
            orElse: () => const MapEntry('category', Icons.folder_outlined))
        .key;
  }
} 