import 'package:get_it/get_it.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/repositories/event_repository.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 注册 SettingsBloc 为单例
  getIt.registerLazySingleton(() => SettingsBloc());
}

Future<void> initDependencies() async {
  LoggerUtils.i('Starting storage initialization...', 'DI');

  final storage = StorageService();
  await storage.init();
  LoggerUtils.i('Storage path: ${storage.storagePath}', 'DI');  // 在注册为单例前打印
  
  getIt.registerSingleton<StorageService>(storage);
  getIt.registerSingleton<EventRepository>(
    EventRepository(storage: storage),
  );
  getIt.registerFactory<EventBloc>(
    () => EventBloc(repository: getIt<EventRepository>()),
  );
}
