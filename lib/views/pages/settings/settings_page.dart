import 'package:flutter/material.dart';
import 'package:remind_me/utils/common/route_utils.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/views/pages/settings/personalization_page.dart';
import 'package:remind_me/views/pages/settings/notification_page.dart';
import 'package:remind_me/views/pages/settings/help_feedback_page.dart';
import 'package:remind_me/views/pages/settings/about_page.dart';
import 'package:remind_me/l10n/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.palette,
            title: context.l10n.personalization,
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const PersonalizationPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.notifications,
            title: context.l10n.notification,
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const NotificationPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.help_outline,
            title: context.l10n.helpAndFeedback,
            onTap: () => Navigator.push(
              context,
              RouteUtils.buildPageRoute(page: const HelpFeedbackPage()),
            ),
          ),
          SettingsListItem(
            icon: Icons.info_outline,
            title: context.l10n.about,
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
