import 'package:flutter/material.dart';
import 'package:remind_me/views/pages/date/date_page.dart';
import 'package:remind_me/views/pages/time/time_page.dart';
import 'package:remind_me/views/pages/settings/settings_page.dart';

/// 应用路由配置
class AppRouter {
  // 路由名称常量
  static const String initial = '/';
  static const String date = '/date';
  static const String time = '/time';
  static const String settings = '/settings';  // 改名为 settingsRoute

  /// 路由生成器
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final String? name = routeSettings.name;
    
    if (name == initial || name == date) {
      return MaterialPageRoute(builder: (_) => const DatePage());
    }
    
    if (name == time) {
      return MaterialPageRoute(builder: (_) => const TimePage());
    }
    
    if (name == settings) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    }

    // 未定义的路由显示错误页面
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for $name'),
        ),
      ),
    );
  }
}
