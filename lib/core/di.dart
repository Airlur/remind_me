import 'package:get_it/get_it.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 注册 SettingsBloc 为单例
  getIt.registerLazySingleton(() => SettingsBloc());
}

Future<void> initDependencies() async {
  final storage = StorageService();
  await storage.init();
  
  getIt.registerSingleton<StorageService>(storage);
  getIt.registerFactory<EventBloc>(() => EventBloc());
}
