import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:remind_me/l10n/l10n.dart';

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
  // LoggerUtils.i('【Time Check】_now called for $title: $now', 'Event');
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

  // 获取序数词后缀（仅用于英文）
  String _getOrdinalSuffix(int number, BuildContext context) {
    final l10n = context.l10n;
    if (Localizations.localeOf(context).languageCode != 'en') return '';
    
    if (number >= 11 && number <= 13) return l10n.ordinalSuffixOther;
    switch (number % 10) {
      case 1: return l10n.ordinalSuffix1;
      case 2: return l10n.ordinalSuffix2;
      case 3: return l10n.ordinalSuffix3;
      default: return l10n.ordinalSuffixOther;
    }
  }

  // 获取前缀
  String getDisplayPrefix(BuildContext context) {
    final l10n = context.l10n;
    
    if (isToday) {
      return includeStartDay ? l10n.eventPrefixTodayOrdinal : l10n.eventPrefixToday;
    } else {
      return isCountdown 
          ? l10n.eventPrefixFuture 
          : (includeStartDay ? l10n.eventPrefixPastOrdinal : l10n.eventPrefixPast);
    }
  }

  // 获取显示天数
  String getDisplayDays(BuildContext context) {
    final l10n = context.l10n;
    
    if (absDays == 0) {
      if (includeStartDay) {
        final suffix = _getOrdinalSuffix(1, context);
        return "1$suffix";
      }
      return l10n.eventToday;  // 使用 l10n 的翻译
    }
    
    if (includeStartDay && !isCountdown) {
      final number = absDays + 1;
      final suffix = _getOrdinalSuffix(number, context);
      return "$number$suffix";
    }
    
    return absDays.toString();
  }

  // 获取单位
  String getDisplayUnit(BuildContext context) {
    final l10n = context.l10n;
    if (absDays == 0) {
      return includeStartDay ? " ${l10n.day}" : "";  // 序数词用单数
    }
    return absDays == 1 ? " ${l10n.day}" : " ${l10n.days}";  // 根据天数使用单复数
  }

  String getFormattedNumber(BuildContext context) {
    final l10n = context.l10n;
    
    if (isToday) {
      return includeStartDay 
          ? "1${_getOrdinalSuffix(1, context)} ${l10n.day}"
          : l10n.eventToday;
    }
    
    // 计算显示的天数
    int displayDays = absDays;
    if (!isCountdown && includeStartDay) {
      displayDays += 1;
    }
    
    switch (displayUnit) {
      case TimeUnit.day:
        return "$displayDays ${displayDays == 1 ? l10n.day : l10n.days}";
        
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
        
        // 如果包含开始日期且不是倒计时，调整天数
        if (!isCountdown && includeStartDay && days == 0) {
          days = 1;
        }

        // 如果不足一年，返回天数让 toggleUnit 跳过
        if (years == 0) return "$displayDays ${displayDays == 1 ? l10n.day : l10n.days}";

        final firstLine = [
          "$years ${years == 1 ? l10n.yearShort : l10n.yearsShort}",
          if (months > 0) "$months ${months == 1 ? l10n.monthShort : l10n.monthsShort}",
        ].join(' ');
        
        if (days > 0) {
          final secondLine = "$days ${days == 1 ? l10n.dayShort : l10n.dayShort}";
          // 使用特殊字符来标记第二行，UI层会处理居中
          return "$firstLine\n$secondLine";
        }
        return firstLine;
        
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
        if (totalMonths == 0) return "$displayDays ${displayDays == 1 ? l10n.day : l10n.days}";

        final mainPart = "$totalMonths ${totalMonths == 1 ? l10n.monthShort : l10n.monthsShort}";
        if (days > 0) {
          final secondPart = "$days ${days == 1 ? l10n.dayShort : l10n.dayShort}";
          return "$mainPart $secondPart"; // 始终在一行显示
        }
        return mainPart;
        
      case TimeUnit.week:
        final weeks = displayDays ~/ 7;
        final remainingDays = displayDays % 7;
        
        // 如果不足一周，返回天数让 toggleUnit 跳过
        if (weeks == 0) return "$displayDays ${displayDays == 1 ? l10n.day : l10n.days}";
        
        final mainPart = "$weeks ${weeks == 1 ? l10n.weekShort : l10n.weeksShort}";
        if (remainingDays > 0) {
          final secondPart = "$remainingDays ${remainingDays == 1 ? l10n.dayShort : l10n.dayShort}";
          return "$mainPart $secondPart"; // 始终在一行显示
        }
        return mainPart;
    }
  }

  // 切换显示单位
  Event toggleUnit(BuildContext context) {
    const units = TimeUnit.values;
    var nextIndex = (units.indexOf(displayUnit) + 1) % units.length;
    
    // 如果下一个单位的显示结果和当前一样，就跳过
    while (nextIndex != units.indexOf(displayUnit)) {
      final nextUnit = units[nextIndex];
      final currentDisplay = getFormattedNumber(context);
      
      // 临时切换单位计算显示值
      final tempEvent = copyWith(displayUnit: nextUnit);
      final nextDisplay = tempEvent.getFormattedNumber(context);
      
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
      backgroundColorValue: backgroundColor?.value ?? backgroundColorValue,
      gradientColorValues: gradientColors?.map((c) => c.value).toList() ?? gradientColorValues,
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
