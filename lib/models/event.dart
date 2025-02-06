import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'event.g.dart';  // part 指令必须在所有导入之后，声明之前

@HiveType(typeId: 1)
enum TimeUnit {
  @HiveField(0)
  day,
  @HiveField(1)
  month,
  @HiveField(2)
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

  const Event({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.createdAt,
    this.displayUnit = TimeUnit.day,
    this.isPinned = false,
    this.backgroundType = BackgroundType.color,
    this.backgroundColorValue,
    this.gradientColorValues,
    this.localImagePath,
    this.animationType,
  });

  Color? get backgroundColor => 
      backgroundColorValue != null ? Color(backgroundColorValue!) : null;
      
  List<Color>? get gradientColors => 
      gradientColorValues?.map((v) => Color(v)).toList();

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
      backgroundColorValue: backgroundColor?.value,
      gradientColorValues: gradientColors?.map((c) => c.value).toList(),
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
    backgroundColorValue,
    gradientColorValues,
    localImagePath,
    animationType,
  ];
}
