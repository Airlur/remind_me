import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}