import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/blocs/settings/settings_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('深色模式'),
                value: state.isDarkMode,
                onChanged: (_) {
                  context.read<SettingsBloc>().add(ToggleThemeEvent());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
