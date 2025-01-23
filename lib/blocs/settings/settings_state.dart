import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;

  const SettingsState({
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
    );
  }
}
