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
  
  // 初始化通知服务
  Future<void> init() async {
    if (_isInitialized) return;
    
    LoggerUtils.i('初始化通知服务', 'NotificationService');
    
    // 初始化时区数据
    LoggerUtils.i('初始化时区数据', 'NotificationService');
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    LoggerUtils.i('本地时区: ${tz.local}', 'NotificationService');
    LoggerUtils.i('结束初始化时区数据', 'NotificationService');

    // 初始化通知插件
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
    
    // 创建专门的闹钟通知通道
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'alarm_channel',
            '闹钟通知',
            description: '用于闹钟样式的通知',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
          ),
        );
        LoggerUtils.i('创建了闹钟通知通道', 'NotificationService');
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
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidImplementation != null) {
        try {
          // 请求通知权限
          hasPermission = await androidImplementation.requestNotificationsPermission() ?? false;
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
      } else {
        // 使用permission_handler作为备选
        hasPermission = await PermissionUtils.requestNotificationPermission();
      }
    } 
    // 在iOS上请求权限
    else if (Platform.isIOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
          
      if (iosImplementation != null) {
        try {
          // 请求iOS通知权限
          hasPermission = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ?? false;
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
  
  // 创建通知
  Future<void> scheduleNotification(Event event) async {
    if (!_isInitialized) await init();
    
    final int notificationId = event.id.hashCode;
    
    LoggerUtils.i('创建通知，ID: $notificationId, 标题: ${event.title}', 'NotificationService');
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      '提醒通知',
      channelDescription: '用于提醒的通知频道',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // 计算通知时间
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      event.reminderTime!,
      tz.local,
    );
    
  LoggerUtils.i('原始提醒时间: ${event.reminderTime}', 'NotificationService');
  LoggerUtils.i('转UTC后时间: ${event.reminderTime!.toUtc()}', 'NotificationService');
  LoggerUtils.i('当前本地时区: ${tz.local}', 'NotificationService');
  LoggerUtils.i('最终调度时间: ${scheduledDate}', 'NotificationService');

  // 检查是否为过去的时间
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  if (scheduledDate.isBefore(now)) {
    LoggerUtils.w('提醒时间已过期，无法创建通知: $scheduledDate < $now', 'NotificationService');
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
      
      LoggerUtils.i('通知已创建，ID: $notificationId, 时间: ${scheduledDate.toString()}', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('创建通知失败: $e', 'NotificationService');
      
      // 如果是权限问题，尝试请求权限
      if (e.toString().contains('exact_alarms_not_permitted') || 
          e.toString().contains('permission')) {
        LoggerUtils.i('尝试请求权限', 'NotificationService');
        final hasPermission = await requestPermission();
        
        if (!hasPermission) {
          // 引导用户去系统设置页面
          final androidImplementation = _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
          if (androidImplementation != null) {
            LoggerUtils.i('打开通知设置页面', 'NotificationService');
            await androidImplementation.createNotificationChannel(const AndroidNotificationChannel(
              'event_reminder_channel',
              '事件提醒',
              description: '用于提醒即将到来的事件',
              importance: Importance.high,
            ));
            
            // 打开应用设置页面
            await PermissionUtils.openSettings();
          }
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
            LoggerUtils.i('重试后通知已创建', 'NotificationService');
          } catch (retryError) {
            LoggerUtils.e('重试创建通知失败: $retryError', 'NotificationService');
          }
        }
      }
    }
  }
  
  // 取消特定事件的通知
  Future<void> cancelNotification(String eventId) async {
    if (!_isInitialized) await init();
    
    final int notificationId = eventId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    LoggerUtils.i('已取消通知，ID: $notificationId', 'NotificationService');
  }
  
  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    
    await _flutterLocalNotificationsPlugin.cancelAll();
    LoggerUtils.i('已取消所有通知', 'NotificationService');
  }
  
  // 检查通知权限状态
  Future<bool> checkPermissionStatus() async {
    final status = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return status ?? false;
  }
  
  // 添加测试通知方法
  Future<void> showTestNotification({bool isAlarmStyle = false}) async {
    if (!_isInitialized) await init();
    
    LoggerUtils.i('显示测试通知，闹钟样式: $isAlarmStyle', 'NotificationService');
    
    const int testNotificationId = 999999;
    
    // 创建通知详情
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alarm_channel',  // 使用专门的闹钟通道
      '闹钟通知',
      channelDescription: '用于闹钟样式的通知',
      importance: Importance.max,
      priority: Priority.max,  // 使用最高优先级
      fullScreenIntent: isAlarmStyle,  // 设置全屏意图
      category: AndroidNotificationCategory.alarm,  // 设置为闹钟类别
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: isAlarmStyle ? const RawResourceAndroidNotificationSound('alarm_sound') : null,
      // 添加以下属性以增加全屏显示的可能性
      ongoing: isAlarmStyle,  // 设置为持续通知
      autoCancel: !isAlarmStyle,  // 闹钟通知不自动取消
      ticker: '闹钟提醒',  // 添加ticker文本
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    try {
      // 显示即时通知
      await _flutterLocalNotificationsPlugin.show(
        testNotificationId,
        '闹钟提醒',  // 使用更明确的标题
        isAlarmStyle ? '这是一个重要的闹钟提醒' : '这是一个普通的测试通知',
        notificationDetails,
        payload: 'test_notification',
      );
      
      LoggerUtils.i('测试通知已显示', 'NotificationService');
    } catch (e) {
      LoggerUtils.e('显示测试通知失败: $e', 'NotificationService');
      
      // 如果是权限问题，尝试请求权限
      if (e.toString().contains('permission')) {
        LoggerUtils.i('尝试请求权限', 'NotificationService');
        final hasPermission = await requestPermission();
        
        if (hasPermission) {
          // 重试显示通知
          await showTestNotification(isAlarmStyle: isAlarmStyle);
        } else {
          // 引导用户到设置页面
          LoggerUtils.i('引导用户到设置页面', 'NotificationService');
          await PermissionUtils.openSettings();
        }
      } else if (e.toString().contains('invalid_sound')) {
        // 如果是声音资源问题，使用默认声音重试
        LoggerUtils.w('声音资源不存在，使用默认声音重试', 'NotificationService');
        
        final AndroidNotificationDetails defaultSoundAndroidDetails = AndroidNotificationDetails(
          'event_reminder_channel',
          '事件提醒',
          channelDescription: '用于提醒即将到来的事件',
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: isAlarmStyle,
          playSound: true,
          // 不指定自定义声音，使用默认声音
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        );
        
        final NotificationDetails defaultSoundNotificationDetails = NotificationDetails(
          android: defaultSoundAndroidDetails,
          iOS: iosDetails,
        );
        
        try {
          await _flutterLocalNotificationsPlugin.show(
            testNotificationId,
            '测试通知',
            isAlarmStyle ? '这是一个闹钟样式的测试通知（默认声音）' : '这是一个普通的测试通知',
            defaultSoundNotificationDetails,
            payload: 'test_notification',
          );
          LoggerUtils.i('使用默认声音的测试通知已显示', 'NotificationService');
        } catch (retryError) {
          LoggerUtils.e('使用默认声音重试失败: $retryError', 'NotificationService');
        }
      }
    }
  }
}
