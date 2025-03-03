import 'package:remind_me/models/event.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/utils/common/logger_utils.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();
  
  final NotificationService _notificationService = NotificationService();
  
  // 初始化提醒服务
  Future<void> init() async {
    LoggerUtils.i('初始化提醒服务', 'ReminderService');
    await _notificationService.init();
    final hasPermission = await _notificationService.requestPermission();
    LoggerUtils.i('通知权限状态: $hasPermission', 'ReminderService');
  }
  
  // 为事件设置提醒
  Future<void> setReminder(Event event) async {
    if (event.reminderTime == null) {
      LoggerUtils.i('事件没有设置提醒时间，跳过', 'ReminderService');
      return;
    }
    
    // 检查事件是否已过期
    if (event.isExpired()) {
      LoggerUtils.i('事件已过期，跳过提醒设置', 'ReminderService');
      return;
    }
    
    LoggerUtils.i('为事件设置提醒: ${event.title}', 'ReminderService');
    
    // 对于非重复事件，直接创建一个通知
    if (event.repeat == null || event.repeat == Repeat.none) {
      await _notificationService.scheduleNotification(event);
      return;
    }
    
    // 对于重复事件，我们需要计算下一次提醒的时间
    final now = DateTime.now();
    DateTime? nextReminderTime;
    
    // 如果提醒时间在未来，使用设置的提醒时间
    if (event.reminderTime!.isAfter(now)) {
      nextReminderTime = event.reminderTime;
    } else {
      // 否则计算下一次重复的时间
      nextReminderTime = event.getNextOccurrence(now);
    }
    
    if (nextReminderTime != null) {
      // 创建一个临时事件对象，使用计算出的下一次提醒时间
      final reminderEvent = Event(
        id: event.id,
        title: event.title,
        targetDate: event.targetDate,
        createdAt: event.createdAt,
        reminderTime: nextReminderTime,
      );
      
      await _notificationService.scheduleNotification(reminderEvent);
    }
  }
  
  // 更新事件的提醒
  Future<void> updateReminder(Event event) async {
    LoggerUtils.i('更新事件提醒: ${event.title}', 'ReminderService');
    
    // 先取消现有提醒
    await cancelReminder(event.id);
    
    // 设置新提醒
    await setReminder(event);
  }
  
  // 取消事件的提醒
  Future<void> cancelReminder(String eventId) async {
    LoggerUtils.i('取消事件提醒: $eventId', 'ReminderService');
    await _notificationService.cancelNotification(eventId);
  }
  
  // 取消所有提醒
  Future<void> cancelAllReminders() async {
    LoggerUtils.i('取消所有提醒', 'ReminderService');
    await _notificationService.cancelAllNotifications();
  }
  
  // 重新设置所有事件的提醒（例如应用启动时）
  Future<void> resetAllReminders(List<Event> events) async {
    LoggerUtils.i('重新设置所有事件的提醒', 'ReminderService');
    
    // 先取消所有提醒
    await cancelAllReminders();
    
    // 为每个事件设置提醒
    for (final event in events) {
      if (event.reminderTime != null) {
        await setReminder(event);
      }
    }
  }
  
  // 添加测试通知方法
  Future<void> showTestNotification({bool isAlarmStyle = false, Duration? delay}) async {
    await _notificationService.showTestNotification(isAlarmStyle: isAlarmStyle, delay: delay);
  }
} 