import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/blocs/settings/settings_event.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  void _showThemeModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('跟随系统'),
                  trailing: Radio<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(UpdateThemeModeEvent(value));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('浅色模式'),
                  trailing: Radio<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(UpdateThemeModeEvent(value));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  trailing: Radio<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: state.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(UpdateThemeModeEvent(value));
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                icon: _getThemeModeIcon(state.themeMode),
                title: '主题',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeModeName(state.themeMode),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showThemeModeBottomSheet(context),
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