import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/constants/colors.dart';
import 'package:remind_me/core/routes.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/home_page.dart';
import 'package:remind_me/theme/app_theme.dart';
import 'package:remind_me/blocs/settings/language_cubit.dart';
import 'package:remind_me/generated/app_localizations.dart';

class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<LanguageCubit, LanguageMode>(
        builder: (context, languageMode) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp(
                title: 'Remind Me',
                theme: AppTheme.lightTheme.copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    brightness: Brightness.light,
                  ),
                ),
                darkTheme: AppTheme.darkTheme.copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    brightness: Brightness.dark,
                  ),
                ),
                themeMode: settingsState.themeMode,
                locale: context.read<LanguageCubit>().locale,
                onGenerateRoute: AppRouter.onGenerateRoute,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
