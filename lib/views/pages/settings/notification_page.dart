import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/l10n/l10n.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notification),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.notifications_active,
            title: context.l10n.reminderNotification,
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // 处理开关变化
              },
            ),
          ),
          SettingsListItem(
            icon: Icons.volume_up,
            title: context.l10n.sound,
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // 处理开关变化
              },
            ),
          ),
        ],
      ),
    );
  }
} 