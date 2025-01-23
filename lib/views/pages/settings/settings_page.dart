import 'package:flutter/material.dart';
import 'package:remind_me/utils/route_utils.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/views/pages/settings/personalization_page.dart';
import 'package:remind_me/views/pages/settings/notification_page.dart';
import 'package:remind_me/views/pages/settings/help_feedback_page.dart';
import 'package:remind_me/views/pages/settings/about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.palette,
            title: '个性化',
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const PersonalizationPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.notifications,
            title: '通知',
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const NotificationPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.help_outline,
            title: '帮助和反馈',
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const HelpFeedbackPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.info_outline,
            title: '关于',
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const AboutPage()),
            ),
          ),
        ],
      ),
    );
  }
}
