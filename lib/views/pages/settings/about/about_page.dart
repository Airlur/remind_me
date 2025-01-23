import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/l10n/l10n.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.about),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.info,
            title: context.l10n.versionInfo,
            trailing: const Text('1.0.0'),
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.privacy_tip,
            title: context.l10n.privacyPolicy,
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.description,
            title: context.l10n.userAgreement,
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.backup,
            title: context.l10n.backupInfo,
            onTap: () {
              // 处理点击
            },
          ),
        ],
      ),
    );
  }
} 