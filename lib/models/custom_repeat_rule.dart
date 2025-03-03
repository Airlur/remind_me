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
        // 如果没有选择星期，则简单地加上周数
        if (weekdays.isEmpty) {
          return from.add(Duration(days: interval * 7));
        }
        
        // 否则，找到下一个匹配的星期
        var next = from.add(const Duration(days: 1));
        while (!weekdays.contains((next.weekday % 7) + 1)) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      
      case RepeatUnit.month:
        // 简单实现：加上月数
        var year = from.year;
        var month = from.month + interval;
        
        while (month > 12) {
          year++;
          month -= 12;
        }
        
        // 处理月底日期
        var day = from.day;
        var daysInMonth = DateTime(year, month + 1, 0).day;
        if (day > daysInMonth) {
          day = daysInMonth;
        }
        
        return DateTime(year, month, day);
      
      case RepeatUnit.year:
        return DateTime(from.year + interval, from.month, from.day);
    }
  }

  // 检查日期是否匹配规则
  bool matches(DateTime date) {
    if (unit == RepeatUnit.week && weekdays.isNotEmpty) {
      return weekdays.contains((date.weekday % 7) + 1);
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