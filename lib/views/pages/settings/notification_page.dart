import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.notifications_active,
            title: '提醒通知',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // 处理开关变化
              },
            ),
          ),
          SettingsListItem(
            icon: Icons.volume_up,
            title: '声音',
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