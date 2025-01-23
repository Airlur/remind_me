import 'package:get_it/get_it.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 注册 SettingsBloc 为单例
  getIt.registerLazySingleton(() => SettingsBloc());
}
