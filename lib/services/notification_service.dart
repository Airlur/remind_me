import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:remind_me/models/event.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:remind_me/utils/common/permission_utils.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const int testNotificationId = 999999;

  // 通知通道ID常量
  static const String reminderChannelId = 'reminder_channel';
  static const String testChannelId = 'test_channel';

  // 初始化通知服务
  Future<void> init() async {
    if (_isInitialized) return;

    LoggerUtils.i('【通知服务】开始初始化', 'NotificationService');

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
      LoggerUtils.e('【通知服务】时区设置失败: $e', 'NotificationService');
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
        // 创建提醒通道
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            reminderChannelId,
            '提醒通知',
            description: '用于事件提醒的通知通道',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            showBadge: true,
          ),
        );

        // 创建测试通道
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            testChannelId,
            '测试通知',
            description: '用于测试的通知通道',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            showBadge: true,
          ),
        );

        // 检查通道创建状态
        final channels = await androidImplementation.getNotificationChannels();
        LoggerUtils.i('【通知服务】已创建通道: ${channels?.map((c) => c.id).toList()}', 
            'NotificationService');
      }
    }

    _isInitialized = true;
    LoggerUtils.i('【通知服务】初始化完成', 'NotificationService');
  }

  /// 处理通知点击事件
  void _onNotificationTap(NotificationResponse response) {
    LoggerUtils.i('【通知服务】通知被点击: ${response.payload}', 'NotificationService');
  }

  // 请求通知权限
  Future<bool> requestPermission() async {
    if (!_isInitialized) await init();

    LoggerUtils.i('【通知服务】开始请求权限', 'NotificationService');

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

          // 检查精确闹钟权限
          final hasExactAlarmPermission =
              await androidImplementation.canScheduleExactNotifications() ??
                  false;
          LoggerUtils.i(
              '精确闹钟权限状态: $hasExactAlarmPermission', 'NotificationService');

          if (!hasExactAlarmPermission) {
            await androidImplementation.requestExactAlarmsPermission();
          }
        } catch (e) {
          LoggerUtils.e('【通知服务】请求权限失败: $e', 'NotificationService');
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

  /// 创建正式提醒通知
  Future<void> scheduleNotification(Event event) async {
    if (!_isInitialized) await init();
    
    final int notificationId = event.id.hashCode;
    LoggerUtils.i('''【提醒通知】开始创建:
      事件ID: ${event.id}
      标题: ${event.title}
      提醒时间: ${event.reminderTime}''', 'NotificationService');

    // 时区转换
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

    // 检查是否为过去时间
    final now = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(now)) {
      LoggerUtils.w('【提醒通知】时间已过期: $scheduledDate < $now', 'NotificationService');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        event.title,
        '即将开始',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            reminderChannelId,
            '提醒通知',
            channelDescription: '用于事件提醒的通知',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      LoggerUtils.i('【提醒通知】创建成功', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('【提醒通知】创建失败: $e', 'NotificationService');
      rethrow;
    }
  }

  /// 测试即时通知
  Future<void> testInstantNotification() async {
    if (!_isInitialized) await init();
    
    LoggerUtils.i('【测试通知】开始测试即时通知', 'NotificationService');
    
    try {
      // 检查权限
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        LoggerUtils.e('【测试通知】权限不足', 'NotificationService');
        return;
      }

      // 发送即时通知
      await _flutterLocalNotificationsPlugin.show(
        testNotificationId,
        '测试通知',
        '这是一条即时测试通知',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            testChannelId,
            '测试通知',
            channelDescription: '用于测试的通知通道',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
          ),
        ),
      );
      LoggerUtils.i('【测试通知】即时通知发送成功', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('【测试通知】发送失败: $e', 'NotificationService');
      rethrow;
    }
  }

  /// 测试定时通知（添加系统检查）
  Future<void> testDelayedNotification(Duration delay) async {
    if (!_isInitialized) await init();
    
    LoggerUtils.i('【测试通知】开始测试定时通知', 'NotificationService');
    
    // 先检查系统设置
    await _checkSystemSettings();
    
    try {
      // 检查权限
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        LoggerUtils.e('【测试通知】权限不足', 'NotificationService');
        return;
      }

      // 计算触发时间
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(delay);
      
      LoggerUtils.i('''【测试通知】定时信息:
        当前时间: $now
        预计触发: $scheduledDate
        延迟时间: ${delay.inSeconds}秒''', 'NotificationService');

      // 设置定时通知
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        testNotificationId,
        '定时测试通知',
        '预计延迟 ${delay.inSeconds} 秒',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            testChannelId,
            '测试通知',
            channelDescription: '用于测试的通知通道',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            playSound: true,
            enableLights: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // 验证设置
      await _checkPendingNotification(testNotificationId, scheduledDate);

      // 延迟检查
      Future.delayed(delay + const Duration(seconds: 1), () async {
        LoggerUtils.i('【测试通知】检查通知状态 - 预期触发后', 'NotificationService');
        await _checkPendingNotification(testNotificationId, scheduledDate);
      });

    } catch (e) {
      LoggerUtils.e('【测试通知】设置失败: $e', 'NotificationService');
      rethrow;
    }
  }

  /// 检查特定通知的状态
  Future<void> _checkPendingNotification(int id, tz.TZDateTime scheduledDate) async {
    // 检查待处理通知
    final pendingNotifications = 
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    final hasPending = pendingNotifications.any((n) => n.id == id);
    
    // 检查活动通知（仅限 Android）
    bool hasActive = false;
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final activeNotifications = 
          await androidImplementation?.getActiveNotifications() ?? [];
      hasActive = activeNotifications.any((n) => n.id == id);
    }

    LoggerUtils.i('''【测试通知】通知状态检查:
      通知ID: $id
      预期触发时间: $scheduledDate
      当前时间: ${tz.TZDateTime.now(tz.local)}
      在待处理队列中: $hasPending
      在活动通知中: $hasActive''', 'NotificationService');
  }

  /// 取消特定通知
  Future<void> cancelNotification(String eventId) async {
    if (!_isInitialized) await init();
    final notificationId = eventId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    LoggerUtils.i('【通知服务】已取消通知: $notificationId', 'NotificationService');
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancelAll();
    LoggerUtils.i('【通知服务】已取消所有通知', 'NotificationService');
  }

  /// 检查系统设置和权限状态
  Future<void> _checkSystemSettings() async {
    if (!Platform.isAndroid) return;

    try {
      // 1. 获取设备信息
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      LoggerUtils.i('''【系统检查】设备信息:
        Android版本: ${deviceInfo.version.release}
        SDK版本: ${deviceInfo.version.sdkInt}
        制造商: ${deviceInfo.manufacturer}
        型号: ${deviceInfo.model}''', 'NotificationService');

      // 2. 获取应用信息
      final packageInfo = await PackageInfo.fromPlatform();
      LoggerUtils.i('''【系统检查】应用信息:
        包名: ${packageInfo.packageName}
        版本: ${packageInfo.version}''', 'NotificationService');

      // 3. 检查通知相关权限
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        // 3.1 通知权限
        final areNotificationsEnabled = 
            await androidImplementation.areNotificationsEnabled() ?? false;
        
        // 3.2 精确闹钟权限
        final canScheduleExactAlarms = 
            await androidImplementation.canScheduleExactNotifications() ?? false;

        // 3.3 电池优化设置
        final isIgnoringBatteryOptimizations = 
            await PermissionUtils.checkBatteryOptimization();

        LoggerUtils.i('''【系统检查】权限状态:
          通知权限: $areNotificationsEnabled
          精确闹钟: $canScheduleExactAlarms
          忽略电池优化: $isIgnoringBatteryOptimizations''', 'NotificationService');

        if (!isIgnoringBatteryOptimizations) {
          LoggerUtils.w('【系统检查】应用未被设置为忽略电池优化', 'NotificationService');
          // 请求忽略电池优化
          await PermissionUtils.requestBatteryOptimization();
        }
      }
    } catch (e) {
      LoggerUtils.e('【系统检查】检查失败: $e', 'NotificationService');
    }
  }

}
