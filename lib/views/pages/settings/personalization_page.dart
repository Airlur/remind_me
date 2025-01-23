import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/blocs/settings/settings_event.dart';
import 'package:remind_me/views/widgets/common/settings_list_item.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/blocs/settings/language_cubit.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return context.l10n.followSystem;
      case ThemeMode.light:
        return context.l10n.lightMode;
      case ThemeMode.dark:
        return context.l10n.darkMode;
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
                  title: Text(context.l10n.followSystem),
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
                  title: Text(context.l10n.lightMode),
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
                  title: Text(context.l10n.darkMode),
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

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<LanguageCubit, LanguageMode>(
        builder: (context, currentMode) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(context.l10n.followSystem),
                  trailing: Radio<LanguageMode>(
                    value: LanguageMode.system,
                    groupValue: currentMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(value);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text(context.l10n.chinese),
                  trailing: Radio<LanguageMode>(
                    value: LanguageMode.zh,
                    groupValue: currentMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(value);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: Text(context.l10n.english),
                  trailing: Radio<LanguageMode>(
                    value: LanguageMode.en,
                    groupValue: currentMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<LanguageCubit>().changeLanguage(value);
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
        title: Text(context.l10n.personalization),
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
                title: context.l10n.theme,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeModeName(context, state.themeMode),
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
                title: context.l10n.language,
                trailing: BlocBuilder<LanguageCubit, LanguageMode>(
                  builder: (context, languageMode) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.read<LanguageCubit>().getLanguageName(context, languageMode),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    );
                  },
                ),
                onTap: () => _showLanguageBottomSheet(context),
              ),
              SettingsListItem(
                icon: Icons.calendar_today,
                title: context.l10n.date,
                onTap: () {
                  // 处理日期设置
                },
              ),
              SettingsListItem(
                icon: Icons.gif_box,
                title: context.l10n.animation,
                onTap: () {
                  // 处理动画背景设置
                },
              ),
              SettingsListItem(
                icon: Icons.widgets,
                title: context.l10n.widgets,
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