import 'package:flutter/material.dart';

abstract class AppColors {
  // 主色调相关
  static const primary = Color(0xFF2196F3);        // 自定义主色调
  static const onPrimary = Colors.white;           // 自定义
  static const primaryContainer = Color(0xFFBBDEFB);// 自定义
  static const onPrimaryContainer = Color(0xFF1976D2);// 自定义

  // 表面/背景相关
  static const surface = Colors.white;              // 卡片、对话框等UI元素的背景
  static const onSurface = Color(0xFF333333);       
  static const surfaceContainer = Color(0xFFF3F3F3);// Material 默认色
  static const surfaceContainerLow = Color(0xFFFBFCFE);// 使用 Material 默认色
  static const surfaceContainerHigh = Color(0xFFECEEF0);// 使用 Material 默认色
  
  // 深色模式
  static const surfaceDark = Color(0xFF121212);     // 自定义
  static const onSurfaceDark = Color(0xFFE0E0E0);   // 自定义
  static const surfaceContainerDark = Color(0xFF1E1E1E); // 自定义
  static const surfaceContainerLowDark = Color(0xFF171717);// 使用 Material 默认色
  static const surfaceContainerHighDark = Color(0xFF252525);// 使用 Material 默认色

  // 背景相关
  static const surfaceTint = Color(0xFFF5F5F5);    // 页面背景色（原来的灰色）
  static const surfaceTintDark = Color(0xFF121212); // 深色模式背景色
  static const background = Color(0xFFF5F5F5);      // 自定义
  static const onBackground = Color(0xFF333333);     // 自定义
  static const backgroundDark = Color(0xFF121212);   // 自定义
  static const onBackgroundDark = Color(0xFFE0E0E0); // 自定义

  // 错误状态相关
  static const error = Color.fromARGB(255, 240, 36, 25);           // Material 默认错误色
  static const onError = Colors.white;              // Material 默认色
  static const errorContainer = Color(0xFFFFDAD6);  // Material 默认色
  static const onErrorContainer = Color(0xFF410E0B);// Material 默认色

  // 滑动操作相关颜色
  static const timelineAction = primary;        // 时间线使用主题蓝色
  static const pinAction = Color(0xFF9C27B0);   // 置顶使用紫色
  static const editAction = Color(0xFFFF9800);  // 编辑使用橙色
  static const deleteAction = error;            // 删除使用错误红色
  
  // 操作按钮文字颜色（如果需要的话）
  static const onActionColor = Colors.white;    // 所有操作按钮的文字/图标颜色
} 