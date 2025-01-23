class SettingsState {
  final bool isDarkMode;

  const SettingsState({this.isDarkMode = false});

  Map<String, dynamic> toJson() => {'isDarkMode': isDarkMode};

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(isDarkMode: json['isDarkMode'] as bool);
  }

  SettingsState copyWith({bool? isDarkMode}) {
    return SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}
