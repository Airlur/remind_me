import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:remind_me/core/app.dart';
import 'package:remind_me/core/di.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
/// 应用程序入口
void main() async {
  // 确保Flutter绑定初始化
  // 这一步是必须的,特别是在调用平台特定代码之前
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 获取应用目录
  Directory appDir = await getApplicationDocumentsDirectory();
  const customStoragePath = 'remind_me_data';
  final storageDir = Directory('${appDir.path}/$customStoragePath');
  await storageDir.create(recursive: true);
  
  // 2. HydratedBloc 使用新目录
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(storageDir.path),
  );

  // 更清晰的日志
  LoggerUtils.i('应用文档目录: ${appDir.path}', 'Main');
  LoggerUtils.i('数据存储目录: ${storageDir.path}', 'Main');
  
  // 3. Hive 使用相同目录
  await Hive.initFlutter(customStoragePath);  // 只传入相对路径即可

  // 注册所有依赖项(服务、bloc等)
  await initializeDependencies();
  await initDependencies();
  LoggerUtils.i('依赖项初始化完成', 'Main');

  // 启动应用程序
  runApp(const RemindMeApp());
}
