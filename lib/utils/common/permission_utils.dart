import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
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
  
  // 请求显示在其他应用上层权限
  static Future<bool> requestOverlayPermission() async {
    // 先检查权限状态
    final status = await Permission.systemAlertWindow.status;
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.systemAlertWindow.request();
    return result.isGranted;
  }
  
  // 检查显示在其他应用上层权限状态
  static Future<bool> checkOverlayPermission() async {
    final status = await Permission.systemAlertWindow.status;
    return status.isGranted;
  }
  
  // 打开应用设置
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// 检查电池优化设置
  static Future<bool> checkBatteryOptimization() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // 检查 Android 版本
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt < 23) return true; // Android 6.0 以下不需要此权限
      
      return await Permission.ignoreBatteryOptimizations.status.isGranted;
    } catch (e) {
      LoggerUtils.e('检查电池优化失败: $e', 'PermissionUtils');
      return false;
    }
  }

  /// 请求忽略电池优化
  static Future<bool> requestBatteryOptimization() async {
    if (!Platform.isAndroid) {
      LoggerUtils.i('【系统检查】非安卓设备，跳过忽略电池优化', 'NotificationService');
      return true;
    }

    try {
      // 先检查权限状态
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isGranted) {
        LoggerUtils.i('【系统检查】已获得忽略电池优化权限', 'NotificationService');
        return true;
      }
      
      // 请求权限
      final result = await Permission.ignoreBatteryOptimizations.request();
      LoggerUtils.i('【系统检查】忽略电池优化请求结果: $result', 'NotificationService');
      
      // 如果权限仍未获得，尝试打开系统设置
      if (!result.isGranted) {
        LoggerUtils.w('【系统检查】未获得权限，尝试打开系统设置', 'NotificationService');
        return await openAppSettings();
      }
      
      return result.isGranted;
    } catch (e) {
      LoggerUtils.e('请求忽略电池优化失败: $e', 'PermissionUtils');
      return false;
    }
  }
}