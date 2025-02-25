import 'package:lunar/lunar.dart';

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
  static String getWeekDay(DateTime date) {
    final weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekDays[date.weekday % 7];
  }
} 