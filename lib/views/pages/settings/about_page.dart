import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.info,
            title: '版本信息',
            trailing: const Text('1.0.0'),
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.policy,
            title: '隐私政策',
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.description,
            title: '用户协议',
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.verified_outlined,
            title: '备案信息',
            onTap: () {
              // 处理点击
            },
          ),
        ],
      ),
    );
  }
} 