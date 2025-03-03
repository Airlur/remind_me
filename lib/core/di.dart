import 'package:get_it/get_it.dart';
import 'package:remind_me/blocs/settings/settings_bloc.dart';
import 'package:remind_me/services/storage_service.dart';
import 'package:remind_me/blocs/event/event_bloc.dart';
import 'package:remind_me/repositories/event_repository.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/services/reminder_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // 注册 SettingsBloc 为单例
  getIt.registerLazySingleton(() => SettingsBloc());
}

Future<void> initDependencies() async {
  LoggerUtils.i('开始初始化依赖项', 'DI');

  final storage = StorageService();
  await storage.init();
  LoggerUtils.i('存储路径: ${storage.storagePath}', 'DI');  // 在注册为单例前打印
  
  getIt.registerSingleton<StorageService>(storage);
  getIt.registerSingleton<EventRepository>(
    EventRepository(storage: storage),
  );
  
  // 注册通知服务
  final notificationService = NotificationService();
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);
  
  // 注册提醒服务
  final reminderService = ReminderService();
  await reminderService.init();
  getIt.registerSingleton<ReminderService>(reminderService);
  
  getIt.registerFactory<EventBloc>(() => EventBloc(
    repository: getIt<EventRepository>(),
    reminderService: getIt<ReminderService>(),
  ));
  
  // 其他依赖注册...
  
  // 在所有服务初始化完成后，重置所有事件的提醒
  final repository = getIt<EventRepository>();
  final events = await repository.getAllEvents();
  // await reminderService.resetAllReminders(events);
  LoggerUtils.i('所有事件已加载：${events.length}', 'DI');
}
