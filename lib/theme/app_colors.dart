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
  static const infoAction = Color.fromARGB(255, 243, 60, 118);  // 详情使用粉色
  static const shareAction = Color(0xFF4CAF50); // 分享使用绿色
  static const editAction = Color(0xFFFF9800);  // 编辑使用橙色
  static const deleteAction = error;            // 删除使用错误红色
  
  // 操作按钮文字颜色（如果需要的话）
  static const onActionColor = Colors.white;    // 所有操作按钮的文字/图标颜色
  static const iconGrayColor = Color(0xFF757175);  // 和Icon灰色相似的字体颜色

  // 预设的纯色背景列表
  static const List<Color> presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Color(0xFFFF0000), // Material Red 500
    Color(0xFF4CAF50), // Material Green 500
    Color(0xFF00FFFF), // Material Cyan 500
    Color(0xFF3F51B5), // Material Indigo 500
    Color(0xFF607D8B), // Material Blue Grey 500
    Color(0xFFFFC107), // Material Amber 500
    Color(0xFFFF9800), // Material Orange 500
    Color(0xFFFF5722), // Material Deep Orange 500
    Color(0xFF795548), // Material Brown 500
    Color(0xFF9C27B0), // Material Purple 500
    Color(0xFFFFEB3B), // Material Yellow 500
    Color(0xFF00BCD4), // Material Cyan 500
  ];
  
  // 预设的渐变色背景列表
  static const List<List<Color>> presetGradients = [
    // 红色系渐变
    [Color(0xFFFF416C), Color(0xFFFF4B2B)], // 红色到橙色
    [Color(0xFFf85032), Color(0xFFe73827)], // 深红色渐变
    
    // 橙色系渐变
    [Color(0xFFf12711), Color(0xFFf5af19)], // 红色到黄色
    [Color(0xFFFF8008), Color(0xFFFFC837)], // 橙色到黄色
    
    // 黄色系渐变
    [Color(0xFFFFE000), Color(0xFFFFBD00)], // 黄色渐变
    [Color(0xFFF7971E), Color(0xFFFFD200)], // 橙黄色渐变
    
    // 绿色系渐变
    [Color(0xFF11998e), Color(0xFF38ef7d)], // 深绿到浅绿
    [Color(0xFF00b09b), Color(0xFF96c93d)], // 青绿到黄绿
    
    // 蓝色系渐变
    [Color(0xFF2193b0), Color(0xFF6dd5ed)], // 深蓝到浅蓝
    [Color(0xFF4364F7), Color(0xFF6FB1FC)], // 蓝色渐变
    
    // 紫色系渐变
    [Color(0xFF834d9b), Color(0xFFd04ed6)], // 深紫到粉紫
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // 紫色渐变
    
    // 粉色系渐变
    [Color(0xFFee9ca7), Color(0xFFffdde1)], // 粉红色渐变
    [Color(0xFFFF6B6B), Color(0xFFFF8E8E)], // 红粉色渐变
    
    // 多彩渐变
    [Color(0xFF1A2980), Color(0xFF26D0CE)], // 深蓝到青色
    [Color(0xFFFF512F), Color(0xFFDD2476)], // 橙色到粉色
    [Color(0xFF614385), Color(0xFF516395)], // 紫色到蓝紫色
    [Color(0xFF02AABD), Color(0xFF00CDAC)], // 青色到绿色
    [Color(0xFFFF5F6D), Color(0xFFFFC371)], // 红色到橙黄色
    [Color(0xFF396afc), Color(0xFF2948ff)], // 蓝色渐变
    [Color(0xFFcc2b5e), Color(0xFF753a88)], // 红色到紫色
    [Color(0xFF42275a), Color(0xFF734b6d)], // 深紫到浅紫
    [Color(0xFF141E30), Color(0xFF243B55)], // 深蓝色渐变
  ];
} 