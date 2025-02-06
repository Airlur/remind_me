import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

enum EventType {
  countdown, // 倒数日
  countup,   // 正数日
}

// 时间单位枚举
enum TimeUnit {
  day,    // 天
  month,  // 月/天
  week    // 周/天
}

// 背景类型枚举
enum BackgroundType {
  color,      // 纯色背景
  gradient,   // 渐变背景
  image,      // 本地图片
  animation   // 动画背景
}

class Event extends Equatable {
  final String id;
  final String title;
  final DateTime targetDate;
  final DateTime createdAt;
  final TimeUnit displayUnit;
  final bool isPinned;
  
  // 背景相关
  final BackgroundType backgroundType;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final String? localImagePath;
  final String? animationType;

  const Event({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.createdAt,
    this.displayUnit = TimeUnit.day,
    this.isPinned = false,
    this.backgroundType = BackgroundType.color,
    this.backgroundColor,
    this.gradientColors,
    this.localImagePath,
    this.animationType,
  });

  // 计算属性
  bool get isCountdown => targetDate.isAfter(DateTime.now());
  
  String get displayPrefix => isCountdown ? '还有' : '已经';
  
  int get daysLeft {
    final difference = targetDate.difference(DateTime.now()).inDays;
    return difference.abs(); // 取绝对值，因为可能是正数或负数
  }

  // 格式化显示数字
  String getFormattedNumber() {
    switch (displayUnit) {
      case TimeUnit.day:
        return '$daysLeft';
      case TimeUnit.month:
        final months = daysLeft ~/ 30;
        final remainingDays = daysLeft % 30;
        return months > 0 
            ? '$months月${remainingDays}天' 
            : '$remainingDays天';
      case TimeUnit.week:
        final weeks = daysLeft ~/ 7;
        final remainingDays = daysLeft % 7;
        return weeks > 0 
            ? '$weeks周${remainingDays}天' 
            : '$remainingDays天';
    }
  }

  // 切换显示单位
  Event toggleUnit() {
    final units = TimeUnit.values;
    final nextIndex = (units.indexOf(displayUnit) + 1) % units.length;
    return copyWith(displayUnit: units[nextIndex]);
  }

  // 复制对象并修改部分属性
  Event copyWith({
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
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      displayUnit: displayUnit ?? this.displayUnit,
      isPinned: isPinned ?? this.isPinned,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientColors: gradientColors ?? this.gradientColors,
      localImagePath: localImagePath ?? this.localImagePath,
      animationType: animationType ?? this.animationType,
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
    backgroundType,
    backgroundColor,
    gradientColors,
    localImagePath,
    animationType,
  ];
}
