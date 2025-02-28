import 'package:lunar/lunar.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/l10n/l10n.dart';

class LunarUtils {
  // 将公历日期转换为农历日期字符串
  static String solarToLunarString(DateTime date) {
    try {
      final lunar = Lunar.fromDate(date);
      return '${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
    } catch (e) {
      return '农历转换错误';
    }
  }
  
  // 格式化日期显示，根据isLunar决定显示公历还是农历
  static String formatDate(DateTime date, bool isLunar) {
    if (!isLunar) {
      // 公历格式: 2025-03-23
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      // 农历格式: 乙巳年三月廿四
      final lunar = Lunar.fromDate(date);
      return '${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
    }
  }
  
  // 获取星期几
  static String getWeekDay(DateTime date, BuildContext context, {bool useShort = false}) {
    final l10n = context.l10n;
    
    switch (date.weekday) {
      case DateTime.monday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.mondayShort
            : l10n.monday;
      case DateTime.tuesday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.tuesdayShort
            : l10n.tuesday;
      case DateTime.wednesday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.wednesdayShort
            : l10n.wednesday;
      case DateTime.thursday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.thursdayShort
            : l10n.thursday;
      case DateTime.friday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.fridayShort
            : l10n.friday;
      case DateTime.saturday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.saturdayShort
            : l10n.saturday;
      case DateTime.sunday:
        return useShort && Localizations.localeOf(context).languageCode == 'en'
            ? l10n.sundayShort
            : l10n.sunday;
      default:
        return '';
    }
  }

  static String formatDateWithYear(DateTime date, bool isLunar, BuildContext context) {
    if (isLunar) {
      final lunarDate = getLunarDate(date);
      final solarYear = date.year;
      return '($solarYear) $lunarDate'; // 在农历年份前添加公历年份
    } else {
      return formatDate(date, false);
    }
  }

  static String getLunarDate(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return '${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  }
} 