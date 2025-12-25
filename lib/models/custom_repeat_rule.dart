import 'package:hive/hive.dart';

part 'custom_repeat_rule.g.dart';

@HiveType(typeId: 5)
enum RepeatUnit {
  @HiveField(0)
  day,
  @HiveField(1)
  week,
  @HiveField(2)
  month,
  @HiveField(3)
  year
}

@HiveType(typeId: 6)
class CustomRepeatRule {
  @HiveField(0)
  final int interval; // 重复间隔
  
  @HiveField(1)
  final RepeatUnit unit; // 重复单位（日、周、月、年）
  
  @HiveField(2)
  final List<int> weekdays; // 选中的星期（1-7，表示周一到周日）
  
  @HiveField(3)
  final List<int> monthDays; // 选中的月份日期（1-31）
  
  @HiveField(4)
  final DateTime? endDate; // 结束日期，null表示永不结束

  CustomRepeatRule({
    required this.interval,
    required this.unit,
    this.weekdays = const [],
    this.monthDays = const [],
    this.endDate,
  });

  // 计算下一次重复的日期
  DateTime getNextOccurrence(DateTime from) {
    switch (unit) {
      case RepeatUnit.day:
        return from.add(Duration(days: interval));
      case RepeatUnit.week:
        if (weekdays.isEmpty) {
          return from.add(Duration(days: interval * 7));
        }

        final startOfWeek = DateTime(from.year, from.month, from.day)
            .subtract(Duration(days: from.weekday - 1));
        var next = from.add(const Duration(days: 1));
        var safety = 0;
        while (safety < 4000) {
          final currentWeekStart = DateTime(next.year, next.month, next.day)
              .subtract(Duration(days: next.weekday - 1));
          final weekDiff = currentWeekStart.difference(startOfWeek).inDays ~/ 7;
          if (weekDiff % interval == 0 && weekdays.contains(next.weekday)) {
            return next;
          }
          next = next.add(const Duration(days: 1));
          safety++;
        }
        return next;
      
      case RepeatUnit.month:
        if (monthDays.isEmpty) {
          var year = from.year;
          var month = from.month + interval;

          while (month > 12) {
            year++;
            month -= 12;
          }

          var day = from.day;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          if (day > daysInMonth) {
            day = daysInMonth;
          }

          return DateTime(year, month, day);
        }

        final startMonth = DateTime(from.year, from.month, 1);
        var candidate = from.add(const Duration(days: 1));
        var safety = 0;
        while (safety < 4000) {
          final monthsDiff =
              (candidate.year - startMonth.year) * 12 + (candidate.month - startMonth.month);
          if (monthsDiff % interval == 0 && monthDays.contains(candidate.day)) {
            return candidate;
          }
          candidate = candidate.add(const Duration(days: 1));
          safety++;
        }
        return candidate;
      
      case RepeatUnit.year:
        return DateTime(from.year + interval, from.month, from.day);
    }
  }

  // 检查日期是否匹配规则
  bool matches(DateTime date) {
    if (unit == RepeatUnit.week && weekdays.isNotEmpty) {
      return weekdays.contains(date.weekday);
    }
    
    if (unit == RepeatUnit.month && monthDays.isNotEmpty) {
      return monthDays.contains(date.day);
    }
    
    return true;
  }

  // 获取描述文本
  String getDescription() {
    String unitText = '';
    switch (unit) {
      case RepeatUnit.day:
        unitText = interval == 1 ? '天' : '$interval天';
        break;
      case RepeatUnit.week:
        unitText = interval == 1 ? '周' : '$interval周';
        break;
      case RepeatUnit.month:
        unitText = interval == 1 ? '月' : '$interval个月';
        break;
      case RepeatUnit.year:
        unitText = interval == 1 ? '年' : '$interval年';
        break;
    }
    
    String weekdaysText = '';
    if (unit == RepeatUnit.week && weekdays.isNotEmpty) {
      final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      weekdaysText = '，每${weekdays.map((w) => weekdayNames[w - 1]).join('、')}';
    }
    
    return '每$unitText$weekdaysText';
  }
} 
