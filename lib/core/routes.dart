import 'package:flutter/material.dart';
import 'package:remind_me/views/pages/date/date_page.dart';
import 'package:remind_me/views/pages/time/time_page.dart';
import 'package:remind_me/views/pages/settings/settings_page.dart';
import 'package:remind_me/views/pages/settings/personalization/personalization_page.dart';
import 'package:remind_me/views/pages/settings/notification/notification_page.dart';
import 'package:remind_me/views/pages/settings/help_feedback/help_feedback_page.dart';
import 'package:remind_me/views/pages/settings/about/about_page.dart';
import 'package:remind_me/views/pages/settings/personalization/language_page.dart';
import 'package:remind_me/views/pages/date/add_event_page.dart';

/// 应用路由配置
class AppRouter {
  // 路由名称常量
  static const String initial = '/';
  static const String date = '/date';
  static const String time = '/time';
  static const String settings = '/settings';
  static const String personalization = '/settings/personalization';
  static const String notification = '/settings/notification';
  static const String helpFeedback = '/settings/help-feedback';
  static const String about = '/settings/about';
  static const String language = '/settings/personalization/language';
  static const String addEvent = '/date/add-event';

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

    if (name == personalization) {
      return MaterialPageRoute(builder: (_) => const PersonalizationPage());
    }

    if (name == notification) {
      return MaterialPageRoute(builder: (_) => const NotificationPage());
    }

    if (name == helpFeedback) {
      return MaterialPageRoute(builder: (_) => const HelpFeedbackPage());
    }

    if (name == about) {
      return MaterialPageRoute(builder: (_) => const AboutPage());
    }

    if (name == language) {
      return MaterialPageRoute(builder: (_) => const LanguagePage());
    }

    if (name == addEvent) {
      return MaterialPageRoute(builder: (_) => const AddEventPage());
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
