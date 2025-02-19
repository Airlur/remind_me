import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'event.g.dart';  // part 指令必须在所有导入之后，声明之前

@HiveType(typeId: 1)
enum TimeUnit {
  @HiveField(0)
  day,
  @HiveField(1)
  year,
  @HiveField(2)
  month,
  @HiveField(3)
  week
}

@HiveType(typeId: 2)
enum BackgroundType {
  @HiveField(0)
  color,
  @HiveField(1)
  gradient,
  @HiveField(2)
  image,
  @HiveField(3)
  animation
}

@HiveType(typeId: 0)
class Event extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final DateTime targetDate;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final TimeUnit displayUnit;
  
  @HiveField(5)
  final bool isPinned;
  
  @HiveField(6)
  final BackgroundType backgroundType;
  
  @HiveField(7)
  final int? backgroundColorValue;
  
  @HiveField(8)
  final List<int>? gradientColorValues;
  
  @HiveField(9)
  final String? localImagePath;
  
  @HiveField(10)
  final String? animationType;
  
  @HiveField(11)
  final DateTime? pinnedAt;
  
  @HiveField(12)
  final bool isLunar;

  @HiveField(13)
  final String? category;

  @HiveField(14)
  final int? order;

  @HiveField(15)
  final String? fontFamily;

  @HiveField(16)
  final String? iconName;

  @HiveField(17)
  final DateTime? reminderTime;

  @HiveField(18, defaultValue: false)
  final bool includeStartDay;

  const Event({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.createdAt,
    this.displayUnit = TimeUnit.day,
    this.isPinned = false,
    this.pinnedAt,
    this.backgroundType = BackgroundType.color,
    this.backgroundColorValue,
    this.gradientColorValues,
    this.localImagePath,
    this.animationType,
    this.isLunar = false,
    this.category,
    this.order,
    this.fontFamily,
    this.iconName,
    this.reminderTime,
    this.includeStartDay = false,
  });

  Color? get backgroundColor => 
      backgroundColorValue != null ? Color(backgroundColorValue!) : null;
      
  List<Color>? get gradientColors => 
      gradientColorValues?.map((v) => Color(v)).toList();

  // DateTime get _now => DateTime.now();

  DateTime get _now {
  final now = DateTime.now();
  // print('【Time Check】_now called for $title: $now');
  return now;
}
  bool get isCountdown => targetDate.isAfter(_now);

  bool get isToday {
    final today = DateTime(_now.year, _now.month, _now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return today.isAtSameMomentAs(target);
  }

  int get absDays {
    final today = DateTime(_now.year, _now.month, _now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays.abs();
  }

  String get displayPrefix {
    final prefix = isToday ? '就是' : (isCountdown ? '还有' : '已经');
    return prefix;
  }

  String getFormattedNumber() {
    if (isToday) return '今天';
    
    switch (displayUnit) {
      case TimeUnit.day:
        return '${absDays}天';
        
      case TimeUnit.year:
        // 确保开始日期小于结束日期
        final start = targetDate.isBefore(_now) ? targetDate : _now;
        final end = targetDate.isBefore(_now) ? _now : targetDate;
        
        var years = end.year - start.year;
        var months = end.month - start.month;
        var days = end.day - start.day;
        
        // 处理天数为负的情况
        if (days < 0) {
          months--;
          final lastDayOfPrevMonth = DateTime(end.year, end.month, 0).day;
          days += lastDayOfPrevMonth;
        }
        
        // 处理月份为负的情况
        if (months < 0) {
          years--;
          months += 12;
        }

        // 如果不足一年，返回天数让 toggleUnit 跳过
        if (years == 0) return '${absDays}天';

        // 年月日显示
        return [
          '${years}年',
          if (months > 0) '${months}个月',
          if (days > 0) '${days}天',
        ].join('');
        
      case TimeUnit.month:
        // 确保开始日期小于结束日期
        final start = targetDate.isBefore(_now) ? targetDate : _now;
        final end = targetDate.isBefore(_now) ? _now : targetDate;
        
        var totalMonths = (end.year - start.year) * 12 + (end.month - start.month);
        var days = end.day - start.day;
        
        // 处理天数为负的情况
        if (days < 0) {
          totalMonths--;
          final lastDayOfPrevMonth = DateTime(end.year, end.month, 0).day;
          days += lastDayOfPrevMonth;
        }

        // 如果不足一个月，返回天数让 toggleUnit 跳过
        if (totalMonths == 0) return '${absDays}天';

        // 月日显示
        return [
          '${totalMonths}个月',
          if (days > 0) '${days}天',
        ].join('');
        
      case TimeUnit.week:
        final weeks = absDays ~/ 7;
        final remainingDays = absDays % 7;
        
        // 如果不足一周，返回天数让 toggleUnit 跳过
        if (weeks == 0) return '${absDays}天';
        
        return [
          '${weeks}周',
          if (remainingDays > 0) '${remainingDays}天',
        ].join('');
    }
  }

  // 切换显示单位
  Event toggleUnit() {
    final units = TimeUnit.values;
    var nextIndex = (units.indexOf(displayUnit) + 1) % units.length;
    
    // 如果下一个单位的显示结果和当前一样，就跳过
    while (nextIndex != units.indexOf(displayUnit)) {
      final nextUnit = units[nextIndex];
      final currentDisplay = getFormattedNumber();
      
      // 临时切换单位计算显示值
      final tempEvent = copyWith(displayUnit: nextUnit);
      final nextDisplay = tempEvent.getFormattedNumber();
      
      // 如果显示不同，就使用这个单位
      if (currentDisplay != nextDisplay) {
        break;
      }
      
      // 否则继续尝试下一个单位
      nextIndex = (nextIndex + 1) % units.length;
    }
    
    return copyWith(displayUnit: units[nextIndex]);
  }

  // 复制对象并修改部分属性
  Event copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    DateTime? createdAt,
    TimeUnit? displayUnit,
    bool? isPinned,
    BackgroundType? backgroundType,
    Color? backgroundColor,
    List<Color>? gradientColors,
    String? localImagePath,
    String? animationType,
    DateTime? pinnedAt,
    bool? isLunar,
    String? category,
    int? order,
    String? fontFamily,
    String? iconName,
    DateTime? reminderTime,
    bool? includeStartDay,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      displayUnit: displayUnit ?? this.displayUnit,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColorValue: backgroundColor?.value ?? this.backgroundColorValue,
      gradientColorValues: gradientColors?.map((c) => c.value).toList() ?? this.gradientColorValues,
      localImagePath: localImagePath ?? this.localImagePath,
      animationType: animationType ?? this.animationType,
      isLunar: isLunar ?? this.isLunar,
      category: category ?? this.category,
      order: order ?? this.order,
      fontFamily: fontFamily ?? this.fontFamily,
      iconName: iconName ?? this.iconName,
      reminderTime: reminderTime ?? this.reminderTime,
      includeStartDay: includeStartDay ?? this.includeStartDay,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    title, 
    targetDate,
    createdAt,
    displayUnit,
    isPinned,
    pinnedAt,
    backgroundType,
    backgroundColorValue,
    gradientColorValues,
    localImagePath,
    animationType,
    isLunar,
    category,
    order,
    fontFamily,
    iconName,
    reminderTime,
    includeStartDay,
  ];
}
