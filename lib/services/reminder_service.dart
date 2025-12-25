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

    LoggerUtils.i('为事件设置提醒: ${event.title}', 'ReminderService');

    final now = DateTime.now();
    final endBoundary = _endOfDay(event.endTime);
    if (endBoundary != null && now.isAfter(endBoundary)) {
      LoggerUtils.i('事件已超过结束时间，跳过提醒设置', 'ReminderService');
      return;
    }

    if (event.repeat == null || event.repeat == Repeat.none) {
      final reminderTime = event.reminderTime!;
      if (endBoundary != null && reminderTime.isAfter(endBoundary)) {
        LoggerUtils.i('提醒时间超过结束时间，跳过提醒设置', 'ReminderService');
        return;
      }
      if (reminderTime.isBefore(now)) {
        LoggerUtils.i('提醒时间已过期，跳过提醒设置', 'ReminderService');
        return;
      }
      await _notificationService.scheduleNotification(event);
      return;
    }

    final offset = _getReminderOffset(event);
    if (offset == null) {
      LoggerUtils.w('提醒时间缺失，无法计算重复提醒', 'ReminderService');
      return;
    }

    DateTime? occurrence = _nextOccurrenceDate(event, now);
    var safety = 0;
    while (occurrence != null && safety < 3650) {
      final reminderTime = _applyOffset(occurrence, offset);
      if (endBoundary != null && reminderTime.isAfter(endBoundary)) {
        LoggerUtils.i('提醒时间超过结束时间，跳过提醒设置', 'ReminderService');
        return;
      }
      if (reminderTime.isAfter(now)) {
        final reminderEvent = event.copyWith(reminderTime: reminderTime);
        await _notificationService.scheduleNotification(reminderEvent);
        return;
      }
      occurrence = _nextOccurrenceDate(event, occurrence.add(const Duration(days: 1)));
      safety++;
    }
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _endOfDay(DateTime? date) {
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  Duration? _getReminderOffset(Event event) {
    final reminderTime = event.reminderTime;
    if (reminderTime == null) return null;
    final baseDate = _stripTime(event.targetDate);
    return reminderTime.difference(baseDate);
  }

  DateTime _applyOffset(DateTime date, Duration offset) {
    return _stripTime(date).add(offset);
  }

  DateTime? _nextOccurrenceDate(Event event, DateTime from) {
    final baseDate = _stripTime(event.targetDate);
    final fromDate = _stripTime(from);

    if (event.repeat == null || event.repeat == Repeat.none) {
      return baseDate;
    }

    final repeat = event.repeat!;
    switch (repeat) {
      case Repeat.daily:
        return _nextByDays(baseDate, fromDate, 1);
      case Repeat.weekly:
        return _nextByDays(baseDate, fromDate, 7);
      case Repeat.monthly:
        return _nextByMonths(baseDate, fromDate, 1);
      case Repeat.yearly:
        return _nextByYears(baseDate, fromDate, 1);
      case Repeat.custom:
        return _nextCustomOccurrence(event, fromDate);
      case Repeat.none:
        return baseDate;
    }
  }

  DateTime _nextByDays(DateTime base, DateTime from, int intervalDays) {
    if (!from.isAfter(base)) {
      return base;
    }
    final diffDays = from.difference(base).inDays;
    final remainder = diffDays % intervalDays;
    final addDays = remainder == 0 ? diffDays : diffDays + (intervalDays - remainder);
    return base.add(Duration(days: addDays));
  }

  DateTime _nextByMonths(DateTime base, DateTime from, int intervalMonths) {
    if (!from.isAfter(base)) {
      return base;
    }
    final monthsDiff = (from.year - base.year) * 12 + (from.month - base.month);
    final cycles = monthsDiff ~/ intervalMonths;
    var candidate = _addMonths(base, cycles * intervalMonths);
    while (candidate.isBefore(from)) {
      candidate = _addMonths(candidate, intervalMonths);
    }
    return candidate;
  }

  DateTime _nextByYears(DateTime base, DateTime from, int intervalYears) {
    if (!from.isAfter(base)) {
      return base;
    }
    final yearsDiff = from.year - base.year;
    final cycles = yearsDiff ~/ intervalYears;
    var candidate = _addYears(base, cycles * intervalYears);
    while (candidate.isBefore(from)) {
      candidate = _addYears(candidate, intervalYears);
    }
    return candidate;
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    var year = date.year;
    var month = date.month + monthsToAdd;
    while (month > 12) {
      year++;
      month -= 12;
    }
    while (month < 1) {
      year--;
      month += 12;
    }
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }

  DateTime _addYears(DateTime date, int yearsToAdd) {
    final year = date.year + yearsToAdd;
    final daysInMonth = DateTime(year, date.month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, date.month, day);
  }

  DateTime? _nextCustomOccurrence(Event event, DateTime fromDate) {
    final rule = event.customRepeatRule;
    if (rule == null) return null;
    final baseDate = _stripTime(event.targetDate);
    var candidate = baseDate.isAfter(fromDate) ? baseDate : fromDate;

    if (!candidate.isBefore(baseDate) && rule.matches(candidate)) {
      return candidate;
    }

    var safety = 0;
    var next = rule.getNextOccurrence(candidate);
    while (safety < 3650) {
      if (!next.isBefore(baseDate) && !next.isBefore(fromDate) && rule.matches(next)) {
        return next;
      }
      next = rule.getNextOccurrence(next);
      safety++;
    }
    return next;
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

  /// 测试通知功能
  Future<void> testNotification({bool isDelayed = false}) async {
    try {
      if (isDelayed) {
        await _notificationService.testDelayedNotification(const Duration(seconds: 10));
        LoggerUtils.i('【提醒服务】定时通知测试已设置', 'ReminderService');
      } else {
        await _notificationService.testInstantNotification();
        LoggerUtils.i('【提醒服务】即时通知测试已发送', 'ReminderService');
      }
    } catch (e) {
      LoggerUtils.e('【提醒服务】通知测试失败: $e', 'ReminderService');
      rethrow;
    }
  }
} 
