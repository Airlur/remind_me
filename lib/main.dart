import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:remind_me/core/app.dart';
import 'package:remind_me/core/di.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 应用程序入口
void main() async {
  // 确保Flutter绑定初始化
  // 这一步是必须的,特别是在调用平台特定代码之前
  WidgetsFlutterBinding.ensureInitialized();

  // 获取应用程序的文档目录
  Directory appDocDir = await getApplicationDocumentsDirectory();
  // 初始化HydratedBloc的存储，并指定存储目录
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: appDocDir,
  );

  // 初始化Hive数据库
  // Hive是一个轻量级的NoSQL数据库,用于本地数据存储
  await Hive.initFlutter();

  // 注册所有依赖项(服务、bloc等)
  await initializeDependencies();

  // 启动应用程序
  runApp(const RemindMeApp());
}