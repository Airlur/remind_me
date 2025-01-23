import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';  // 使用相对路径

export '../generated/app_localizations.dart';

/// 便捷访问本地化文本的扩展方法
/// 使用: context.l10n.someText
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}