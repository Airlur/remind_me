import 'package:flutter/material.dart';
import 'dart:io';
import 'package:remind_me/models/event.dart';

class BackgroundUtils {
  /// 构建事件背景装饰
  static BoxDecoration buildBackgroundDecoration({
    required BackgroundType backgroundType,
    Color? backgroundColor,
    List<Color>? gradientColors,
    String? localImagePath,
    Color defaultColor = Colors.white,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) {
    switch (backgroundType) {
      case BackgroundType.color:
        return BoxDecoration(
          color: backgroundColor ?? defaultColor,
          borderRadius: borderRadius,
        );
      case BackgroundType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? [defaultColor, defaultColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
        );
      case BackgroundType.image:
        return BoxDecoration(
          image: localImagePath != null
              ? DecorationImage(
                  image: FileImage(File(localImagePath)),
                  fit: BoxFit.cover,
                )
              : null,
          color: defaultColor, // 添加默认背景色，以防图片加载失败
          borderRadius: borderRadius,
        );
      case BackgroundType.animation:
        // 动画背景暂时使用默认颜色
        return BoxDecoration(
          color: defaultColor,
          borderRadius: borderRadius,
        );
    }
  }

  /// 判断背景是否为深色
  static bool isBackgroundDark({
    required BackgroundType backgroundType,
    Color? backgroundColor,
    List<Color>? gradientColors,
  }) {
    switch (backgroundType) {
      case BackgroundType.color:
        if (backgroundColor == null) return false;
        return _isDarkColor(backgroundColor);
      
      case BackgroundType.gradient:
        if (gradientColors == null || gradientColors.isEmpty) return false;
        // 对于渐变色，我们检查第一个颜色
        return _isDarkColor(gradientColors.first);
      
      case BackgroundType.image:
        // 对于图片背景，我们默认使用深色文字
        // 实际应用中可能需要分析图片的主色调
        return false;
      
      case BackgroundType.animation:
        // 对于动画背景，我们默认使用深色文字
        return false;
    }
  }

  /// 判断颜色是否为深色
  static bool _isDarkColor(Color color) {
    // 使用 HSL 亮度计算，亮度小于 0.5 认为是深色
    final brightness = color.computeLuminance();
    return brightness < 0.5;
  }

  /// 根据背景获取适合的文字颜色
  static Color getTextColor({
    required BackgroundType backgroundType,
    Color? backgroundColor,
    List<Color>? gradientColors,
    Color lightTextColor = Colors.white,
    Color darkTextColor = Colors.black,
  }) {
    final isDark = isBackgroundDark(
      backgroundType: backgroundType,
      backgroundColor: backgroundColor,
      gradientColors: gradientColors,
    );
    
    return isDark ? lightTextColor : darkTextColor;
  }

  /// 获取事件卡片背景装饰
  static BoxDecoration getEventCardBackground(Event event, BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme.surface;
    
    return buildBackgroundDecoration(
      backgroundType: event.backgroundType,
      backgroundColor: event.backgroundColor,
      gradientColors: event.gradientColors,
      localImagePath: event.localImagePath,
      defaultColor: defaultColor,
    );
  }

  /// 获取事件卡片文字颜色
  static Color getEventTextColor(Event event, BuildContext context) {
    final defaultDarkColor = Theme.of(context).colorScheme.onSurface;
    const defaultLightColor = Colors.white;
    
    return getTextColor(
      backgroundType: event.backgroundType,
      backgroundColor: event.backgroundColor,
      gradientColors: event.gradientColors,
      lightTextColor: defaultLightColor,
      darkTextColor: defaultDarkColor,
    );
  }
} 