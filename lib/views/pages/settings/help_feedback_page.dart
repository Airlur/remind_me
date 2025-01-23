import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助和反馈'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.help,
            title: '使用帮助',
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.feedback,
            title: '意见反馈',
            onTap: () {
              // 处理点击
            },
          ),
        ],
      ),
    );
  }
} 