import 'package:hive_flutter/hive_flutter.dart';
import 'package:remind_me/models/event.dart';
import 'package:remind_me/utils/common/logger_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageService {
  static const String eventBoxName = 'events';
  static const String customStoragePath = 'remind_me_data';  // 保持和 main.dart 一致

  late Box<Event> _eventBox;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final storagePath = '${appDir.path}/$customStoragePath';
    
    // 确保存储目录存在
    await Directory(storagePath).create(recursive: true);
    
    // 初始化 Hive
    await Hive.initFlutter(customStoragePath);  // 只传入相对路径
    
    // 注册适配器
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(TimeUnitAdapter());
    Hive.registerAdapter(BackgroundTypeAdapter());
    
    _eventBox = await Hive.openBox<Event>(eventBoxName);
    LoggerUtils.i('事件存储初始化完成，路径: ${_eventBox.path}', 'StorageService');
  }

  // 获取存储路径
  String? get storagePath => _eventBox.path;

  // 获取所有事件
  Future<List<Event>> getAllEvents() async {
    final events = _eventBox.values.toList();
    LoggerUtils.i('获取所有事件: ${events.length}', 'StorageService');
    return events;
  }

  // 保存事件
  Future<void> saveEvent(Event event) async {
    LoggerUtils.i('新建事件 - Title: ${event.title}, Order: ${event.order}', 'StorageService');
    await _eventBox.put(event.id, event);
  }

  // 更新事件
  Future<void> updateEvent(Event event) async {
    LoggerUtils.i('更新事件 - Title: ${event.title}, Order: ${event.order}', 'StorageService');
    await _eventBox.put(event.id, event);
  }

  // 批量保存事件【原拖拽排序使用的方法，已废弃】
  Future<void> saveEvents(List<Event> events) async {
    final Map<String, Event> eventMap = {
      for (var event in events) event.id: event
    };
    await _eventBox.putAll(eventMap);
  }

  // 删除事件
  Future<void> deleteEvent(String eventId) async {
    await _eventBox.delete(eventId);
  }

  // 清空所有事件
  Future<void> clearEvents() async {
    await _eventBox.clear();
  }

  // 批量更新事件
  Future<void> updateEvents(List<Event> events) async {
    LoggerUtils.i(
      '批量更新事件 - 数量: ${events.length}, 事件列表:\n${events.map((e) => '  ${e.title}(order: ${e.order})').join(',\n')}',
      'StorageService'
    );
    final batch = events.fold<Map<String, Event>>({}, (map, event) {
      map[event.id] = event;
      return map;
    });
    await _eventBox.putAll(batch);
  }
}
