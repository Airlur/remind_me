import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/blocs/settings/settings_event.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个性化'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsListItem(
                icon: Icons.dark_mode,
                title: '深色模式',
                trailing: Switch(
                  value: state.isDarkMode,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(ToggleThemeEvent());
                  },
                ),
              ),
              SettingsListItem(
                icon: Icons.language,
                title: '语言',
                onTap: () {
                  // 处理语言设置
                },
              ),
              SettingsListItem(
                icon: Icons.calendar_today,
                title: '日期',
                onTap: () {
                  // 处理日期设置
                },
              ),
              SettingsListItem(
                icon: Icons.gif_box,
                title: '动画背景',
                onTap: () {
                  // 处理动画背景设置
                },
              ),
              SettingsListItem(
                icon: Icons.widgets,
                title: '小组件',
                onTap: () {
                  // 处理小组件设置
                },
              ),
            ],
          );
        },
      ),
    );
  }
}