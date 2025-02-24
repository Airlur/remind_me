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