import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/utils/common/permission_utils.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  AndroidScheduleMode? _cachedScheduleMode;
  bool? _isXiaomiDevice;

  static const int testNotificationId = 999999;
  static const String reminderChannelId = 'reminder_channel_v4';
  static const String testChannelId = 'test_channel_v4';
  static const List<String> _legacyChannelIds = [
    'reminder_channel',
    'test_channel',
    'reminder_channel_v2',
    'test_channel_v2',
    'reminder_channel_v3',
    'test_channel_v3',
  ];

  Future<AndroidScheduleMode> _getAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    if (_cachedScheduleMode != null) {
      return _cachedScheduleMode!;
    }

    final manufacturer = await _getManufacturer();
    if (_isXiaomi(manufacturer)) {
      _cachedScheduleMode = AndroidScheduleMode.alarmClock;
    } else {
      _cachedScheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }

    LoggerUtils.i(
      'Schedule mode set to $_cachedScheduleMode for $manufacturer',
      'NotificationService',
    );
    return _cachedScheduleMode!;
  }

  Future<String> _getManufacturer() async {
    if (!Platform.isAndroid) return 'unknown';
    if (_isXiaomiDevice != null) {
      return _isXiaomiDevice! ? 'xiaomi' : 'other';
    }
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final manufacturer = deviceInfo.manufacturer.toLowerCase();
    _isXiaomiDevice = _isXiaomi(manufacturer);
    return manufacturer;
  }

  bool _isXiaomi(String manufacturer) {
    return manufacturer.contains('xiaomi') ||
        manufacturer.contains('redmi') ||
        manufacturer.contains('poco');
  }

  Future<bool> _shouldUseFullScreenIntent() async {
    if (!Platform.isAndroid) return false;
    final manufacturer = await _getManufacturer();
    return _isXiaomi(manufacturer);
  }

  Future<void> init() async {
    if (_isInitialized) return;

    LoggerUtils.i('Notification service init start', 'NotificationService');

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
      final now = DateTime.now();
      LoggerUtils.i('System time: $now', 'NotificationService');
      LoggerUtils.i('Time zone set: ${tz.local}', 'NotificationService');
      LoggerUtils.i(
        'Timezone offset: ${tz.local.currentTimeZone.offset}',
        'NotificationService',
      );
    } catch (e) {
      LoggerUtils.e('Time zone init failed: $e', 'NotificationService');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        for (final channelId in _legacyChannelIds) {
          try {
            await androidImplementation.deleteNotificationChannel(channelId);
          } catch (e) {
            LoggerUtils.w(
              'Delete legacy channel failed: $channelId ($e)',
              'NotificationService',
            );
          }
        }

        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            reminderChannelId,
            'Reminder Notifications v4',
            description: 'Notifications for event reminders',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );

        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            testChannelId,
            'Test Notifications v4',
            description: 'Notifications for testing',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );

        final channels = await androidImplementation.getNotificationChannels();
        LoggerUtils.i(
          'Channels created: ${channels?.map((c) => c.id).toList()}',
          'NotificationService',
        );
      }
    }

    _isInitialized = true;
    LoggerUtils.i('Notification service init done', 'NotificationService');
  }

  void _onNotificationTap(NotificationResponse response) {
    LoggerUtils.i(
      'Notification tapped: ${response.payload}',
      'NotificationService',
    );
  }

  Future<bool> requestPermission() async {
    if (!_isInitialized) await init();

    LoggerUtils.i('Requesting notification permission', 'NotificationService');

    var hasPermission = false;

    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        try {
          hasPermission =
              await androidImplementation.requestNotificationsPermission() ??
                  false;
          LoggerUtils.i(
            'Android notification permission: $hasPermission',
            'NotificationService',
          );

          final hasExactAlarmPermission =
              await androidImplementation.canScheduleExactNotifications() ??
                  false;
          LoggerUtils.i(
            'Exact alarm permission: $hasExactAlarmPermission',
            'NotificationService',
          );

          if (!hasExactAlarmPermission) {
            await androidImplementation.requestExactAlarmsPermission();
          }
        } catch (e) {
          LoggerUtils.e(
            'Permission request failed: $e',
            'NotificationService',
          );
          hasPermission = await PermissionUtils.requestNotificationPermission();
        }
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        try {
          hasPermission = await iosImplementation.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
          LoggerUtils.i(
            'iOS notification permission: $hasPermission',
            'NotificationService',
          );
        } catch (e) {
          LoggerUtils.e('iOS permission request failed: $e', 'NotificationService');
          hasPermission = false;
        }
      }
    }

    LoggerUtils.i(
      'Notification permission final: $hasPermission',
      'NotificationService',
    );
    return hasPermission;
  }

  Future<void> scheduleNotification(Event event) async {
    if (!_isInitialized) await init();

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      LoggerUtils.e('Notification permission denied', 'NotificationService');
      return;
    }

    final notificationId = event.id.hashCode;
    LoggerUtils.i(
      'Schedule reminder: id=${event.id}, title=${event.title}, time=${event.reminderTime}',
      'NotificationService',
    );

    final reminderTime = event.reminderTime!;
    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderTime.year,
      reminderTime.month,
      reminderTime.day,
      reminderTime.hour,
      reminderTime.minute,
      reminderTime.second,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(now)) {
      LoggerUtils.w(
        'Scheduled time is in the past: $scheduledDate < $now',
        'NotificationService',
      );
      return;
    }

    try {
      final scheduleMode = await _getAndroidScheduleMode();
      final useFullScreenIntent = await _shouldUseFullScreenIntent();
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        event.title,
        'Starts soon',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            reminderChannelId,
            'Reminder Notifications v4',
            channelDescription: 'Notifications for event reminders',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
            fullScreenIntent: useFullScreenIntent,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
      );
      LoggerUtils.i('Reminder scheduled', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('Schedule reminder failed: $e', 'NotificationService');
      rethrow;
    }
  }

  Future<void> testInstantNotification() async {
    if (!_isInitialized) await init();

    LoggerUtils.i('Test instant notification', 'NotificationService');

    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        LoggerUtils.e('Notification permission denied', 'NotificationService');
        return;
      }

      final useFullScreenIntent = await _shouldUseFullScreenIntent();
      await _flutterLocalNotificationsPlugin.show(
        testNotificationId,
        'Test Notification',
        'This is an instant test notification',
        NotificationDetails(
          android: AndroidNotificationDetails(
            testChannelId,
            'Test Notifications v4',
            channelDescription: 'Notifications for testing',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
            fullScreenIntent: useFullScreenIntent,
          ),
        ),
      );
      LoggerUtils.i('Instant test notification sent', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('Instant test failed: $e', 'NotificationService');
      rethrow;
    }
  }

  Future<void> testDelayedNotification(Duration delay) async {
    if (!_isInitialized) await init();

    LoggerUtils.i('Test delayed notification', 'NotificationService');

    await _checkSystemSettings();

    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        LoggerUtils.e('Notification permission denied', 'NotificationService');
        return;
      }

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(delay);

      LoggerUtils.i(
        'Delayed test: now=$now, scheduled=$scheduledDate, delay=${delay.inSeconds}s',
        'NotificationService',
      );

      final scheduleMode = await _getAndroidScheduleMode();
      final useFullScreenIntent = await _shouldUseFullScreenIntent();
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        testNotificationId,
        'Delayed Test Notification',
        'Scheduled after ${delay.inSeconds} seconds',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            testChannelId,
            'Test Notifications v4',
            channelDescription: 'Notifications for testing',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
            fullScreenIntent: useFullScreenIntent,
          ),
        ),
        androidScheduleMode: scheduleMode,
      );

      await _checkPendingNotification(testNotificationId, scheduledDate);

      Future.delayed(delay + const Duration(seconds: 1), () async {
        LoggerUtils.i('Delayed test check after fire time', 'NotificationService');
        await _checkPendingNotification(testNotificationId, scheduledDate);
      });
    } catch (e) {
      LoggerUtils.e('Delayed test failed: $e', 'NotificationService');
      rethrow;
    }
  }

  Future<void> _checkPendingNotification(
    int id,
    tz.TZDateTime scheduledDate,
  ) async {
    final pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    final hasPending = pendingNotifications.any((n) => n.id == id);

    var hasActive = false;
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final activeNotifications =
          await androidImplementation?.getActiveNotifications() ?? [];
      hasActive = activeNotifications.any((n) => n.id == id);
    }

    LoggerUtils.i(
      'Notification status: id=$id scheduled=$scheduledDate now=${tz.TZDateTime.now(tz.local)} pending=$hasPending active=$hasActive',
      'NotificationService',
    );
  }

  Future<void> cancelNotification(String eventId) async {
    if (!_isInitialized) await init();
    final notificationId = eventId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    LoggerUtils.i('Notification cancelled: $notificationId', 'NotificationService');
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancelAll();
    LoggerUtils.i('All notifications cancelled', 'NotificationService');
  }

  Future<void> _checkSystemSettings() async {
    if (!Platform.isAndroid) return;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      LoggerUtils.i(
        'Device info: Android ${deviceInfo.version.release}, SDK ${deviceInfo.version.sdkInt}, ${deviceInfo.manufacturer} ${deviceInfo.model}',
        'NotificationService',
      );

      final packageInfo = await PackageInfo.fromPlatform();
      LoggerUtils.i(
        'App info: ${packageInfo.packageName} ${packageInfo.version}',
        'NotificationService',
      );

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final areNotificationsEnabled =
            await androidImplementation.areNotificationsEnabled() ?? false;
        final canScheduleExactAlarms =
            await androidImplementation.canScheduleExactNotifications() ?? false;
        final isIgnoringBatteryOptimizations =
            await PermissionUtils.checkBatteryOptimization();

        LoggerUtils.i(
          'Permissions: notifications=$areNotificationsEnabled exactAlarm=$canScheduleExactAlarms ignoreBatteryOpt=$isIgnoringBatteryOptimizations',
          'NotificationService',
        );

        if (!isIgnoringBatteryOptimizations) {
          LoggerUtils.w(
            'Battery optimization not ignored',
            'NotificationService',
          );
          await PermissionUtils.requestBatteryOptimization();
        }
      }
    } catch (e) {
      LoggerUtils.e('System check failed: $e', 'NotificationService');
    }
  }
}
