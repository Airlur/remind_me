import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:remind_me/l10n/l10n.dart';

enum LanguageMode { system, zh, en }

class LanguageCubit extends HydratedCubit<LanguageMode> {
  LanguageCubit() : super(LanguageMode.system);

  void changeLanguage(LanguageMode mode) => emit(mode);

  Locale? get locale {
    switch (state) {
      case LanguageMode.system:
        return null; // 返回 null 表示跟随系统
      case LanguageMode.zh:
        return const Locale('zh');
      case LanguageMode.en:
        return const Locale('en');
    }
  }

  String getLanguageName(BuildContext context, LanguageMode mode) {
    switch (mode) {
      case LanguageMode.system:
        return context.l10n.followSystem;
      case LanguageMode.zh:
        return context.l10n.chinese;
      case LanguageMode.en:
        return context.l10n.english;
    }
  }

  @override
  LanguageMode fromJson(Map<String, dynamic> json) {
    return LanguageMode.values[json['mode'] as int];
  }

  @override
  Map<String, dynamic> toJson(LanguageMode state) {
    return {'mode': state.index};
  }
} 