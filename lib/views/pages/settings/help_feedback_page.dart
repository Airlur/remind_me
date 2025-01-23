import 'package:flutter/material.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/l10n/l10n.dart';

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.helpAndFeedback),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsListItem(
            icon: Icons.help,
            title: context.l10n.userHelp,
            onTap: () {
              // 处理点击
            },
          ),
          SettingsListItem(
            icon: Icons.feedback,
            title: context.l10n.feedback,
            onTap: () {
              // 处理点击
            },
          ),
        ],
      ),
    );
  }
} 