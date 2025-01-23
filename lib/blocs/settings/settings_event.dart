import 'package:flutter/material.dart';

abstract class SettingsEvent {}

class UpdateThemeModeEvent extends SettingsEvent {
  final ThemeMode themeMode;
  UpdateThemeModeEvent(this.themeMode);
}
