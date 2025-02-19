import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/blocs/settings/settings_state.dart';
import 'package:remind_me/core/routes.dart';
import 'package:remind_me/l10n/l10n.dart';
import 'package:remind_me/views/pages/home_page.dart';
import 'package:remind_me/theme/app_theme.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/blocs/settings/language_cubit.dart';
import 'package:remind_me/generated/app_localizations.dart';
import 'package:remind_me/core/di.dart';


class RemindMeApp extends StatelessWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (context) => getIt<EventBloc>(),  // 直接获取 EventBloc 实例
        ),
        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<LanguageCubit, LanguageMode>(
        builder: (context, languageMode) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp(
                builder: (context, child) {
                  return Localizations.override(
                    context: context,
                    delegates: AppLocalizations.localizationsDelegates,
                    child: Builder(
                      builder: (context) => child ?? const SizedBox(),
                    ),
                  );
                },
                debugShowCheckedModeBanner: false,  // 关闭 "debug" 标签
                title: AppLocalizations.of(context)?.appName ?? '醒我',
                theme: AppTheme.lightTheme,         // 使用我们的主题
                darkTheme: AppTheme.darkTheme,      // 使用我们的暗色主题
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
