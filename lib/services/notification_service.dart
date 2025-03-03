import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:remind_me/models/event.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/utils/common/permission_utils.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const int testNotificationId = 999999;

  // 初始化通知服务
  Future<void> init() async {
    if (_isInitialized) return;

    LoggerUtils.i('开始初始化通知服务', 'NotificationService');

    try {
      // 初始化时区数据
      tz_data.initializeTimeZones();

      // 直接设置为上海时区（UTC+8）
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

      // 打印时区信息用于调试
      final now = DateTime.now();
      LoggerUtils.i('系统时间: $now', 'NotificationService');
      LoggerUtils.i('设置时区成功: ${tz.local}', 'NotificationService');
      LoggerUtils.i(
          '当前时区偏移: ${tz.local.currentTimeZone.offset}', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('设置时区失败: $e', 'NotificationService');
      // 这里可以不需要再次设置，因为上面已经尝试过了
    }

    // 初始化通知插件
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 创建通知通道
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // 创建测试通知通道
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'test_channel',
            '测试通知',
            description: '用于测试的通知通道',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            enableLights: true,
            showBadge: true,
          ),
        );

        // 创建正式提醒通道
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'reminder_channel',
            '提醒通知',
            description: '用于事件提醒的通知',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            enableLights: true,
            showBadge: true,
          ),
        );

        // 请求精确闹钟权限
        await androidImplementation.requestExactAlarmsPermission();

        // 检查权限状态
        final hasExactAlarmPermission =
            await androidImplementation.canScheduleExactNotifications() ??
                false;
        LoggerUtils.i(
            '精确闹钟权限状态: $hasExactAlarmPermission', 'NotificationService');
      }
    }

    _isInitialized = true;
    LoggerUtils.i('通知服务初始化完成', 'NotificationService');
  }

  // 处理通知点击事件
  void _onNotificationTap(NotificationResponse response) {
    LoggerUtils.i('通知被点击，payload: ${response.payload}', 'NotificationService');
    // 这里可以添加导航到事件详情页的逻辑
  }

  // 请求通知权限
  Future<bool> requestPermission() async {
    if (!_isInitialized) await init();

    LoggerUtils.i('请求通知权限', 'NotificationService');

    bool hasPermission = false;

    // 在 Android 上请求权限
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        try {
          // 请求通知权限
          hasPermission =
              await androidImplementation.requestNotificationsPermission() ??
                  false;
          LoggerUtils.i('Android通知权限状态: $hasPermission', 'NotificationService');

          // 对于精确闹钟权限，我们无法直接检查，只能在创建通知时捕获异常
          // 如果需要引导用户到设置页面开启精确闹钟权限，可以使用以下代码
          if (hasPermission) {
            LoggerUtils.i('引导用户到应用设置页面开启精确闹钟权限', 'NotificationService');
            // 这里不直接打开设置，而是在创建通知失败时再打开
          }
        } catch (e) {
          LoggerUtils.e('请求Android通知权限失败: $e', 'NotificationService');
          // 使用permission_handler作为备选
          hasPermission = await PermissionUtils.requestNotificationPermission();
        }
      }
    }
    // 在iOS上请求权限
    else if (Platform.isIOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        try {
          // 请求iOS通知权限
          hasPermission = await iosImplementation.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
          LoggerUtils.i('iOS通知权限状态: $hasPermission', 'NotificationService');
        } catch (e) {
          LoggerUtils.e('请求iOS通知权限失败: $e', 'NotificationService');
          hasPermission = false;
        }
      }
    }

    LoggerUtils.i('最终通知权限状态: $hasPermission', 'NotificationService');
    return hasPermission;
  }

  // 创建正式提醒通知
  Future<void> scheduleNotification(Event event) async {
    if (!_isInitialized) await init();

    final int notificationId = event.id.hashCode;

    LoggerUtils.i('【事件提醒】创建提醒通知', 'NotificationService');
    LoggerUtils.i('【事件提醒】事件ID: ${event.id}', 'NotificationService');
    LoggerUtils.i('【事件提醒】事件标题: ${event.title}', 'NotificationService');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      '提醒通知',
      channelDescription: '用于事件提醒的通知',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 更安全的时区转换
    final DateTime reminderTime = event.reminderTime!;
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      reminderTime.year,
      reminderTime.month,
      reminderTime.day,
      reminderTime.hour,
      reminderTime.minute,
      reminderTime.second,
    );

    LoggerUtils.i('【事件提醒】原始提醒时间: ${event.reminderTime}', 'NotificationService');
    LoggerUtils.i(
        '【事件提醒】设备时区: ${DateTime.now().timeZoneName}', 'NotificationService');
    LoggerUtils.i('【事件提醒】转换后时区时间: $scheduledDate', 'NotificationService');

    // 检查是否为过去的时间
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(now)) {
      LoggerUtils.w(
          '【事件提醒】提醒时间已过期，无法创建通知: $scheduledDate < $now', 'NotificationService');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        event.title,
        '即将开始',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: event.id,
      );

      LoggerUtils.i(
          '【事件提醒】通知已创建，ID: $notificationId, 时间: ${scheduledDate.toString()}',
          'NotificationService');
    } catch (e) {
      LoggerUtils.e('【事件提醒】创建通知失败: $e', 'NotificationService');

      // 如果是权限问题，尝试请求权限
      if (e.toString().contains('exact_alarms_not_permitted') ||
          e.toString().contains('permission')) {
        LoggerUtils.i('【事件提醒】尝试请求权限', 'NotificationService');
        final hasPermission = await requestPermission();

        if (!hasPermission) {
          // 引导用户去系统设置页面
          await PermissionUtils.openSettings();
        } else {
          // 重试创建通知
          try {
            await _flutterLocalNotificationsPlugin.zonedSchedule(
              notificationId,
              event.title,
              '即将开始',
              scheduledDate,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: event.id,
            );
            LoggerUtils.i('【事件提醒】重试后通知已创建', 'NotificationService');
          } catch (retryError) {
            LoggerUtils.e('【事件提醒】重试创建通知失败: $retryError', 'NotificationService');
          }
        }
      }
    }
  }

  // 测试通知方法
  Future<void> showTestNotification({
    bool isAlarmStyle = false,
    Duration? delay,
  }) async {
    if (!_isInitialized) await init();

    // 首先确保有通知权限
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      LoggerUtils.e('【测试通知】没有通知权限', 'NotificationService');
      return;
    }

    LoggerUtils.i(
        '【测试通知】显示测试通知，闹钟样式: $isAlarmStyle, 延迟: $delay', 'NotificationService');

    if (delay != null) {
      try {
        await _flutterLocalNotificationsPlugin.cancel(testNotificationId);

        final now = tz.TZDateTime.now(tz.local);
        final scheduledDate = now.add(delay);

        LoggerUtils.i('【测试通知】当前时间: $now', 'NotificationService');
        LoggerUtils.i('【测试通知】设备时区: ${DateTime.now().timeZoneName}',
            'NotificationService');
        LoggerUtils.i('【测试通知】计划通知时间: $scheduledDate', 'NotificationService');

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          testNotificationId,
          isAlarmStyle ? '闹钟提醒' : '测试通知',
          '将在 ${delay.inSeconds} 秒后提醒',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'test_channel',
              '测试通知',
              channelDescription: '用于测试的通知通道',
              importance: Importance.max,
              priority: Priority.max,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              visibility: NotificationVisibility.public,
              sound: RawResourceAndroidNotificationSound('alarm_sound'),
              playSound: true,
              enableLights: true,
              enableVibration: true,
              ongoing: true,
              autoCancel: false,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        LoggerUtils.i('【测试通知】延迟通知设置成功', 'NotificationService');
      } catch (e) {
        LoggerUtils.e('【测试通知】设置延迟通知失败: $e', 'NotificationService');
        rethrow;
      }
    } else {
      await _flutterLocalNotificationsPlugin.show(
        testNotificationId,
        isAlarmStyle ? '闹钟提醒' : '测试通知',
        isAlarmStyle ? '这是一个闹钟测试' : '这是一个测试通知',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            '测试通知',
            channelDescription: '用于测试的通知通道',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            playSound: true,
            enableLights: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  // 取消特定事件的通知
  Future<void> cancelNotification(String eventId) async {
    if (!_isInitialized) await init();

    final int notificationId = eventId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    LoggerUtils.i('【事件提醒】已取消通知，ID: $notificationId', 'NotificationService');
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();

    await _flutterLocalNotificationsPlugin.cancelAll();
    LoggerUtils.i('【事件提醒】已取消所有通知', 'NotificationService');
  }

  // 检查通知权限状态
  Future<bool> checkPermissionStatus() async {
    final status = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return status ?? false;
  }
}
