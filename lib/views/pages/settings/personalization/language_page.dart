import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/language_cubit.dart';
import 'package:remind_me/l10n/l10n.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.language),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<LanguageCubit, LanguageMode>(
        builder: (context, currentMode) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageItem(
                    context,
                    title: context.l10n.followSystem,
                    subtitle: '跟随系统',
                    mode: LanguageMode.system,
                    currentMode: currentMode,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                  ),
                  _buildLanguageItem(
                    context,
                    title: '中文',
                    subtitle: 'Chinese',
                    mode: LanguageMode.zh,
                    currentMode: currentMode,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                  ),
                  _buildLanguageItem(
                    context,
                    title: 'English',
                    subtitle: '英文',
                    mode: LanguageMode.en,
                    currentMode: currentMode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required LanguageMode mode,
    required LanguageMode currentMode,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: mode == currentMode ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(mode);
      },
    );
  }
}