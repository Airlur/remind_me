class DateTimeUtils {
  // 获取当前日期的天数
  static int getCurrentDay() {
    return DateTime.now().day;
  }
  
  // 获取当前日期的字符串
  static String getCurrentDayString() {
    return getCurrentDay().toString();
  }
  
  // 获取当前日期
  static String getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
