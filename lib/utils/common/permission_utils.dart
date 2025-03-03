import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionUtils {
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  // 检查通知权限状态
  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
  
  // 打开应用设置
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}