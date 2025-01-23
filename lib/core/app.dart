import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/constants/colors.dart';
import 'package:remind_me/core/routes.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/home_page.dart';
import 'package:remind_me/core/di.dart';
import 'package:remind_me/theme/app_theme.dart';

class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.get<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
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
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRouter.onGenerateRoute,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('zh'), // Chinese
            ],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
